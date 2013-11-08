describe 'Index (/)', ->
  context 'when access token is not in local storage', ->
    beforeEach ->
      AIO.localStorage.set 'accessToken', null

    it 'redirects to sign in screen', (done) ->
      visit('/').thenCheck done, ->
        expect(spec.getCurrentRoute()).to.equal spec.getRoute('sign-in')

  context 'when access token is in local storage', ->
    mainRoute = null

    beforeEach ->
      mainRoute = spec.getRoute 'main'
      sinon.stub mainRoute, 'model'
      AIO.localStorage.set 'accessToken', access_token: 'foobarbazqux', scope: AIO.AccessToken.scope, resource_owner_id: 123

    afterEach ->
      mainRoute.model.restore()

    it 'initializes an access token object and redirects to main screen', (done) ->
      expect(AIO.get 'accessToken').not.to.exist
      visit('/').thenCheck done, ->
        expect(spec.getCurrentRoute()).to.equal spec.getRoute('main.index')
        expect(AIO.get 'accessToken.token').to.equal 'foobarbazqux'
