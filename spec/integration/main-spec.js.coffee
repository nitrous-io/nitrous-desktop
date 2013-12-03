gui = require 'nw.gui'

describe 'Main (/main)', ->
  t = accessToken = null

  beforeEach ->
    accessToken = App.AccessToken.create(accessToken: 'foobarbazqux', scope: App.AccessToken.scope, resource_owner_id: 123)
    accessToken.saveToStorage()
    App.set 'accessToken', accessToken
    t = visit('/main')

  context 'when fetching current user fails with 401 unauthorized', ->
    beforeEach ->
      Em.run ->
        App.set 'currentUser', App.CurrentUser.create()
      server.respondWith 'GET', /\/api\/v0\/user\.json$/, [401, {}, '']

    it 'clears access token and restarts app', (done) ->
      expect(App.get 'accessToken').to.exist
      expect(App.get 'currentUser').to.exist
      server.respond()
      t.thenCheck done, ->
        expect(App.AccessToken.loadFromStorage()).not.to.exist
        win = gui.Window.get()
        expect(gui.Window.open).to.have.been.called
        expect(win.close).to.have.been.called

  context 'when fetching current user succeeds', ->
    mainController = null

    beforeEach ->
      server.respondWith 'GET', /\/api\/v0\/user\.json$/, [
        200
        { 'Content-Type': 'application/json; charset=utf-8' }
        JSON.stringify
          user:
            id: 123
            username: 'pete'
            admin: false
            authentications: []
            confirmed_at: '2013-09-19T05:28:01Z'
            created_at: '2013-09-19T05:27:23Z'
            email: 'pete@example.com'
            full_name: 'Pete Examplename'
            intro_seen: true
            max_n2o: 1000
            used_n2o: 200
            referral_link: '/join/foobar'
            rewardable_invites_count: 10
      ]
      mainController = spec.getController 'main'
      sinon.stub mainController, 'connectToShover'

    afterEach ->
      mainController.connectToShover.restore()

    it 'sets App.currentUser', (done) ->
      expect(App.get 'accessToken').to.exist
      server.respond()
      t.thenCheck done, ->
        currentUser = App.get 'currentUser'
        expect(currentUser).to.exist
        expect(currentUser.get 'id').to.equal 123
        expect(currentUser.get 'username').to.equal 'pete'

    it 'connects to shover', (done) ->
      expect(mainController.connectToShover).not.to.have.been.called
      server.respond()
      t.thenCheck done, ->
        expect(mainController.connectToShover).to.have.been.called
