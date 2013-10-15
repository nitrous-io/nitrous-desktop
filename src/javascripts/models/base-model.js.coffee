AIO.BaseModel = klass = Em.Model.extend
  id: Em.attr()

klass.reopenClass
  camelizeKeys: true
