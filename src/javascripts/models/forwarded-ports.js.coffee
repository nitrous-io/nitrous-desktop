#= require ./forwarded-port

makeKey = (boxId) ->
  "box:#{boxId}:forwardedPorts"

App.ForwardedPorts = klass = Em.ArrayProxy.extend Em.SortableMixin,
  content: Em.computed -> Em.A()
  boxId: null
  sortProperties: ['port']

  sortFunction: (x, y) ->
    return 0 if x == y
    if x < y then -1 else 1

  add: (input) ->
    list = @get 'content'
    port = window.parseInt input, 10
    if port > 0 && port < 65536 && !list.findBy('content', port)
      item = App.ForwardedPort.create port: port
      list.pushObject item
      @save()

  remove: (obj) ->
    @removeObject(obj)
    @save()

  save: ->
    if boxId = @get 'boxId'
      App.localStorage.set makeKey(boxId), @get('arrangedContent').map (p) -> p.get 'port'

klass.reopenClass
  _cache: {}

  forBoxId: (id) ->
    @_cache[id] ||= if ports = App.localStorage.get makeKey(id)
      klass._create boxId: id, content: ports.map((p) -> App.ForwardedPort.create port: p)
    else
      klass._create boxId: id

klass._create = klass.create
klass.create = undefined
