#= require ./base-model

AIO.BoxTemplate = klass = AIO.BaseModel.extend
  name: Em.attr()
  description: Em.attr()
  enabled: Em.attr()
  runtime: Em.attr()

klass.reopenClass
  rootKey: 'box_template'
  collectionKey: 'box_templates'
  url: "#{AIO.get 'config.host'}/api/v0/box_templates"
