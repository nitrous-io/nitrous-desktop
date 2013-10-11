url = require 'url'

describe 'AIO.AccessToken', ->
  accessToken = null

  beforeEach ->
    accessToken = AIO.AccessToken.create
      username: 'pete'
      password: 'foobar'
      clientId: 'deadbeefcafebabe'
      clientSecret: 'b00bbabeb00bbabe'

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
      tokenString = 'abfb852d4e0e4000194920257b28a8100ef5a85ec6840f1db7b89a02ee3c1acf'

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
