describe 'App.CurrentUser', ->
  describedClass = App.CurrentUser
  user = null

  it 'is a subclass of App.BaseModel', ->
    expect(describedClass.prototype).to.be.an.instanceOf App.BaseModel

  beforeEach ->
    user = describedClass.create id: 123

  describe '#getSignInToken', ->
    beforeEach ->
      server.respondWith 'GET', /\/api\/v0\/user\/sign_in_token\.json$/, [
        200
        { 'Content-Type': 'application/json; charset=utf-8' }
        '{"sign_in_token": "FooBarBazQux1234567890"}'
      ]

    it 'does GET sign_in_token on user object, returns a promise to give a sign in token', ->
      promise = user.getSignInToken()
      thenFn = sinon.spy()
      promise.then(thenFn)
      expect(thenFn).not.to.have.been.called
      server.respond()
      expect(thenFn).to.have.been.calledWith 'FooBarBazQux1234567890'
