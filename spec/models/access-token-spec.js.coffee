url = require 'url'

describe 'AIO.AccessToken', ->
  described_class = AIO.AccessToken
  accessToken = null

  beforeEach ->
    described_class.clearCache()
    described_class.singleton = null
    accessToken = described_class.create
      username: 'pete'
      password: 'foobar'
      clientId: 'deadbeefcafebabe'
      clientSecret: 'b00bbabeb00bbabe'

  it 'sets default values', ->
    expect(accessToken.get 'grantType').to.equal 'password'
    expect(accessToken.get 'scope').to.equal 'public boxes push web user'

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
      expect(params.scope).to.equal 'public boxes push web user'
      expect(url.parse(request.url).path).to.equal '/oauth/token.json'

    context 'on response', ->
      tokenString = 'foobarbazqux'

      beforeEach ->
        server.respondWith 'POST', /\/oauth\/token\.json$/, [
            200
            { 'Content-Type': 'application/json; charset=utf-8' }
            JSON.stringify {
              'access_token': tokenString
              'resource_owner_id': 123
              'scope': 'public boxes push web user'
              'token_type': 'bearer'
            }
          ]

      it 'sets token attribute', ->
        expect(accessToken.get 'token').not.to.exist
        server.respond()
        expect(accessToken.get 'token').to.equal tokenString

      it 'sets the singleton attribute on class', ->
        expect(described_class.singleton).to.be.null
        server.respond()
        expect(described_class.singleton).to.equal accessToken

  describe '.saveToStorage', ->
    beforeEach ->
      accessToken = described_class.create token: 'foobarbazqux'
      described_class.singleton = accessToken

    it "saves the class's singleton to local storage", ->
      described_class.saveToStorage()
      json = JSON.parse(JSON.stringify(accessToken.toJSON())) # drop empty items
      expect(AIO.localStorage.get 'accessToken').to.deep.equal json

  describe '.loadFromStorage', ->
    beforeEach ->
      AIO.localStorage.set 'accessToken', access_token: 'foobarbazqux', scope: described_class.scope

    it 'loads and returns the access token from local storage', ->
      accessToken = described_class.loadFromStorage()
      expect(accessToken).to.be.instanceOf described_class
      expect(accessToken.get 'token').to.equal 'foobarbazqux'
      expect(accessToken.get 'scope').to.equal described_class.scope
