describe 'Main (/main)', ->
  t = accessToken = null

  beforeEach ->
    accessToken = AIO.AccessToken.create(accessToken: 'foobarbazqux', scope: AIO.AccessToken.scope, resource_owner_id: 123)
    accessToken.saveToStorage()
    AIO.set 'accessToken', accessToken
    t = visit('/main')

  context 'when fetching current user fails with 401 unauthorized', ->
    beforeEach ->
      Em.run ->
        AIO.set 'currentUser', AIO.CurrentUser.create()
      server.respondWith 'GET', /\/api\/v0\/user\.json$/, [401, {}, '']

    it 'clears access token and redirects to sign in', (done) ->
      expect(AIO.get 'accessToken').to.exist
      expect(AIO.get 'currentUser').to.exist
      server.respond()
      t.thenCheck done, ->
        expect(AIO.get 'accessToken').not.to.exist
        expect(AIO.get 'currentUser').not.to.exist
        expect(AIO.AccessToken.loadFromStorage()).not.to.exist
        expect(spec.getCurrentRoute()).to.equal spec.getRoute('sign-in')

  context 'when fetching current user succeeds', ->
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

    it 'sets AIO.currentUser', (done) ->
      expect(AIO.get 'accessToken').to.exist
      server.respond()
      t.thenCheck done, ->
        currentUser = AIO.get 'currentUser'
        expect(currentUser).to.exist
        expect(currentUser.get 'id').to.equal 123
        expect(currentUser.get 'username').to.equal 'pete'
