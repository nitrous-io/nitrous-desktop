describe 'AIO.OAuthRESTAdapter', ->
  describedClass = AIO.OAuthRESTAdapter
  adapter = null

  beforeEach ->
    adapter = describedClass.create()

  it 'is a subclass of Ember.RESTAdapter', ->
    expect(adapter).to.be.an.instanceOf Ember.RESTAdapter

  describe '#ajaxSettings', ->
    beforeEach ->
      sinon.stub(AIO, 'get').withArgs('accessToken.token').returns 'cafebabe1234'

    afterEach ->
      AIO.get.restore()

    it 'adds Authorization header', ->
      expect(adapter.ajaxSettings().headers).to.have.property 'Authorization', 'Bearer cafebabe1234'
