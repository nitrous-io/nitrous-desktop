#= require ./base-model

AIO.Box = klass = AIO.BaseModel.extend
  name: Em.attr()
  state: Em.attr()

  host: Em.attr()
  port: Em.attr()

  ownerId: Em.attr()
  regionId: Em.attr()

  version: Em.attr()
  memory: Em.attr()
  storage: Em.attr()

  boxServerUri: Em.attr()
  containerName: Em.attr()
  backendAvailable: Em.attr()

  controllable: Em.computed.match 'state', /running|stopped/
  running: Em.computed.equal 'state', 'running'
  stopped: Em.computed.equal 'state', 'stopped'

  currentUserIdBinding: Em.Binding.oneWay 'AIO.currentUser.id'

  ownBox: (->
    @get('currentUserId') == @get('ownerId')
  ).property 'currentUserId', 'ownerId'

  prettyState: (->
    if state = @get 'state'
      if state == 'failed'
        state = 'provisioning_failed'
      if state.match /ed$/
        state = state + '!'
      else if state.match /ing$/
        state = state + '...'

      state = state.split('_').map((t) -> t.capitalize()).join(' ')
  ).property 'state'

klass.reopenClass
  rootKey: 'box'
  collectionKey: 'boxes'
  storageKey: 'boxes'
  url: "#{AIO.get 'settings.host'}/api/v0/boxes"
