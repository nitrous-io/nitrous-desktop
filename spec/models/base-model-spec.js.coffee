describedClass = TestBaseModel = App.BaseModel.extend()

describe 'App.BaseModel', ->
  it 'camelizes keys', ->
    expect(describedClass.camelizeKeys).to.be.true
