describedClass = TestBaseModel = AIO.BaseModel.extend()

describe 'AIO.BaseModel', ->
  it 'camelizes keys', ->
    expect(describedClass.camelizeKeys).to.be.true
