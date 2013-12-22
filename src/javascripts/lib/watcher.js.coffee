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

  _clearNotifyTimeout: ->
    if @notifyTimeout
      window.clearTimeout @notifyTimeout
      @notifyTimeout = null

if os.type() == 'Darwin'
  fsevents = require 'fsevents'
  startedWatchers = []

  App.Watcher::start = ->
    @stop() if @fsevents
    @fsevents = fsevents(@path)
    startedWatchers.push(this)
    @fsevents.on 'change', (path) =>
      @_notify(path)

  App.Watcher::stop = ->
    @_clearNotifyTimeout()
    if @fsevents
      @fsevents.stop()
      @fsevents.removeAllListeners()
      @fsevents = undefined
    index = startedWatchers.indexOf(this)
    startedWatchers.splice(index, 1) if index != -1

  App.Watcher.stopAll = ->
    startedWatchers.forEach (watcher) ->
      watcher.stop()
    startedWatchers = []
