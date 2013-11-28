describe 'App.OAuthRESTAdapter', ->
  describedClass = App.OAuthRESTAdapter
  adapter = null

  beforeEach ->
    adapter = describedClass.create()

  it 'is a subclass of Ember.RESTAdapter', ->
    expect(adapter).to.be.an.instanceOf Ember.RESTAdapter

  describe '#ajaxSettings', ->
    beforeEach ->
      sinon.stub(App, 'get').withArgs('accessToken.token').returns 'cafebabe1234'

    afterEach ->
      App.get.restore()

    it 'adds Authorization header', ->
      expect(adapter.ajaxSettings().headers).to.have.property 'Authorization', 'Bearer cafebabe1234'
