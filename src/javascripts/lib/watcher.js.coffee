EventEmitter = require('events').EventEmitter
os = require 'os'
Path = require 'path'
appPath = require 'app-path'

class App.Watcher extends EventEmitter
  constructor: (@path, options) ->
    options ?= {}
    @ignore = options.ignore ? ['.git', '.svn', '.hg', 'CVS', '.DS_Store', 'Thumbs.db', 'Desktop.ini']
    @delay = options.delay ? 500
    @notifyTimeout = null

  _shouldIgnore: (path) ->
    components = path.split(Path.sep).slice 1
    _.intersection(components, @ignore).length > 0

  _notify: (path) ->
    if @notifyTimeout == null && !@_shouldIgnore(path)
      @notifyTimeout = window.setTimeout(=>
        @notifyTimeout = null
        @emit 'change'
      , @delay)

if os.type() == 'Darwin'
  fsevents = require 'fsevents'

  App.Watcher::start = ->
    @stop() if @fsevents
    @fsevents = fsevents(@path)
    @fsevents.on 'change', (path) =>
      @_notify(path)

  App.Watcher::stop = ->
    if @fsevents
      @fsevents.stop()
      @fsevents.removeAllListeners()
      @fsevents = undefined
