#= require ./base-model

App.Box = klass = App.BaseModel.extend
  region: Em.belongsTo 'App.Region', key: 'region_id'
  boxTemplate: Em.belongsTo 'App.BoxTemplate', key: 'box_template_id'

  name: Em.attr()
  state: Em.attr()

  host: Em.attr()
  port: Em.attr()

  ownerId: Em.attr()

  version: Em.attr()
  memory: Em.attr()
  storage: Em.attr()

  boxServerUri: Em.attr()
  containerName: Em.attr()
  backendAvailable: Em.attr()

  controllable: Em.computed.match 'state', /running|stopped/
  running: Em.computed.equal 'state', 'running'
  stopped: Em.computed.equal 'state', 'stopped'

  ownBox: (->
    App.get('currentUser.id') == @get('ownerId')
  ).property 'App.currentUser.id', 'ownerId'

  prettyState: (->
    if state = @get 'state'
      if state == 'failed'
        state = 'provisioning_failed'
      if state.match /ed$/
        state = state + '!'

      state = state.split('_').map((t) -> t.capitalize()).join(' ')
  ).property 'state'

  start: ->
    @makeRequest 'start', 'POST'

  stop: ->
    @makeRequest 'stop', 'POST'

  restart: ->
    @makeRequest 'restart', 'POST'

klass.reopenClass
  rootKey: 'box'
  collectionKey: 'boxes'
  url: "#{App.get 'config.host'}/api/v0/boxes"
