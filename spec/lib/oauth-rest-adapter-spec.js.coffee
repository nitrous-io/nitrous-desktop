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

  describe '#makeRequest', ->
    FakeModel = Em.Model.extend
      _id: Em.attr()

    FakeModel.reopenClass
      primaryKey: '_id'
      url: 'https://www.example.com'

    beforeEach ->
      sinon.stub adapter, 'ajax'

    context 'when primary key attribute exists', ->
      it 'calls ajax with properly constructed url including the id', ->
        record = FakeModel.create _id: 1337, id: 123
        adapter.makeRequest record, 'update_something', 'PUT', foo: 'bar'
        expect(adapter.ajax).to.have.been.calledWith 'https://www.example.com/1337/update_something.json', { foo: 'bar' }, 'PUT'
        adapter.ajax.reset()

    context 'when primary key attribute does not exist', ->
      it 'calls ajax with url that does not include the id', ->
        record = FakeModel.create()
        adapter.makeRequest record, 'update_something', 'PUT', foo: 'bar'
        expect(adapter.ajax).to.have.been.calledWith 'https://www.example.com/update_something.json', { foo: 'bar' }, 'PUT'
