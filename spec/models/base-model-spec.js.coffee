describedClass = TestBaseModel = App.BaseModel.extend()

describe 'App.BaseModel', ->
  it 'camelizes keys', ->
    expect(describedClass.camelizeKeys).to.be.true

  it 'uses App.OAuthRESTAdapter', ->
    expect(describedClass.adapter).to.be.an.instanceOf App.OAuthRESTAdapter

  describe '#makeRequest', ->
    adapter = describedClass.adapter
    record = TestBaseModel.create()

    beforeEach ->
      sinon.stub adapter, 'makeRequest'

    afterEach ->
      adapter.makeRequest.restore()

    it "delegates to the adapter's makeRequest method", ->
      record.makeRequest 'foo'
      expect(adapter.makeRequest).to.have.been.calledWith record, 'foo', 'GET', undefined
      adapter.makeRequest.reset()

      record.makeRequest 'bar', 'PUT'
      expect(adapter.makeRequest).to.have.been.calledWith record, 'bar', 'PUT', undefined
      adapter.makeRequest.reset()

      record.makeRequest 'baz', 'DELETE', qux: '123'
      expect(adapter.makeRequest).to.have.been.calledWith record, 'baz', 'DELETE', { qux: '123' }
