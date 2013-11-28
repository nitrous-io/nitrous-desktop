#= require ./base-model

App.BoxTemplate = klass = App.BaseModel.extend
  name: Em.attr()
  description: Em.attr()
  enabled: Em.attr()
  runtime: Em.attr()

klass.reopenClass
  rootKey: 'box_template'
  collectionKey: 'box_templates'
  url: "#{App.get 'config.host'}/api/v0/box_templates"
