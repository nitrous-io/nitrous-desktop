described_class = TestBaseModel = AIO.BaseModel.extend()

describe 'AIO.BaseModel', ->
  it 'camelizes keys', ->
    expect(described_class.camelizeKeys).to.be.true
