App.BaseModel = klass = Em.Model.extend
  id: Em.attr()

klass.reopenClass
  adapter: App.OAuthRESTAdapter.create()
  camelizeKeys: true
