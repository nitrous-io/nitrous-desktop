url = require 'url'

describe 'App.AccessToken', ->
  describedClass = App.AccessToken
  accessToken = null

  beforeEach ->
    describedClass.clearCache()
    accessToken = describedClass.create
      username: 'pete'
      password: 'foobar'
      clientId: 'deadbeefcafebabe'
      clientSecret: 'b00bbabeb00bbabe'

  it 'sets default values', ->
    expect(accessToken.get 'grantType').to.equal 'password'
    expect(accessToken.get 'scope').to.equal 'public boxes public_keys push web user'

  describe '#save', ->
    beforeEach ->
      accessToken.save()

    it 'makes a POST request with correct params', ->
      request = server.requests[0]
      expect(request.method).to.equal 'POST'
      params = JSON.parse(request.requestBody)
      expect(params.username).to.equal 'pete'
      expect(params.password).to.equal 'foobar'
      expect(params.client_id).to.equal 'deadbeefcafebabe'
      expect(params.client_secret).to.equal 'b00bbabeb00bbabe'
      expect(params.grant_type).to.equal 'password'
      expect(params.scope).to.equal 'public boxes public_keys push web user'
      expect(url.parse(request.url).path).to.equal '/oauth/token.json'

    context 'on response', ->
      tokenString = 'foobarbazqux'

      beforeEach ->
        server.respondWith 'POST', /\/oauth\/token\.json$/, [
            200
            { 'Content-Type': 'application/json; charset=utf-8' }
            JSON.stringify
              access_token: tokenString
              resource_owner_id: 123
              scope: 'public boxes public_keys push web user'
              token_type: 'bearer'
          ]

      it 'sets token attribute', ->
        expect(accessToken.get 'token').not.to.exist
        server.respond()
        expect(accessToken.get 'token').to.equal tokenString

  describe '#saveToStorage', ->
    beforeEach ->
      accessToken = describedClass.create token: 'foobarbazqux'

    it "saves the access token to local storage", ->
      accessToken.saveToStorage()
      json = JSON.parse(JSON.stringify(accessToken.toJSON())) # drop empty items
      expect(App.localStorage.get 'accessToken').to.deep.equal json

  describe '.loadFromStorage', ->
    beforeEach ->
      App.localStorage.set 'accessToken', access_token: 'foobarbazqux', scope: describedClass.scope

    it 'loads and returns the access token from local storage', ->
      accessToken = describedClass.loadFromStorage()
      expect(accessToken).to.be.instanceOf describedClass
      expect(accessToken.get 'token').to.equal 'foobarbazqux'
      expect(accessToken.get 'scope').to.equal describedClass.scope
