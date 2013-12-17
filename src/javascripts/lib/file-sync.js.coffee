path = require 'path'
fs = require 'fs'
homePath = null
nitrousPath = null

makeKey = (boxId) ->
  "box:#{boxId}:fileSync"

App.FileSync = klass = Em.Object.extend
  enabled: false
  boxId: null

  init: ->
    @_super.apply this, arguments
    @enabledDidChange()

  enabledDidChange: (->
    @save()
    if @get 'enabled'
      if nitrousPath
        @_startObserving()
      else
        App.utility.findHomeFolder (home) =>
          homeFolderPath = home
          nitrousPath = path.join home, 'Nitrous'
          @_startObserving()
  ).observes 'enabled'

  save: ->
    if boxId = @get 'boxId'
      App.localStorage.set makeKey(boxId),
        enabled: @get 'enabled'

  _startObserving: ->
    fs.mkdir nitrousPath, '0755', (err) ->

klass._create = klass.create
klass.create = undefined

klass.reopenClass
  _cache: {}

  forBoxId: (id) ->
    @_cache[id] ||= if settings = App.localStorage.get makeKey(id)
      klass._create boxId: id, enabled: settings.enabled
    else
      klass._create boxId: id
