EventEmitter = require('events').EventEmitter
os = require 'os'
Path = require 'path'

klass = class App.Watcher extends EventEmitter
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
        @emit 'change', path
      , @delay)

  _clearNotifyTimeout: ->
    if @notifyTimeout
      window.clearTimeout @notifyTimeout
      @notifyTimeout = null

klass::start = ->
klass::stop = ->

startedWatchers = []

klass.stopAll = ->
  startedWatchers.forEach (watcher) ->
    watcher.stop()
  startedWatchers = []

if os.type() == 'Darwin'
  fsevents = require 'fsevents'

  klass::start = ->
    @stop() if @fsevents
    @fsevents = fsevents(@path)
    startedWatchers.push(this)
    @fsevents.on 'change', (path) =>
      @_notify(path)

  klass::stop = ->
    @_clearNotifyTimeout()
    if @fsevents
      @fsevents.removeAllListeners()
      @fsevents.stop()
      @fsevents = undefined
    index = startedWatchers.indexOf(this)
    startedWatchers.splice(index, 1) if index != -1

else if os.type() == 'Windows_NT'
  appPath = require 'app-path'
  childProcess = require 'child_process'
  WATCHER_EXE_PATH = Path.join(appPath, 'programs', 'nitrous-watcher.exe')

  klass::start = ->
    @stop() if @proc
    @proc = childProcess.spawn WATCHER_EXE_PATH, [@path], detached: false
    startedWatchers.push(this)
    @proc.stdout.on 'data', (data) => @_processOutput(data)
    @proc.stderr.on 'data', (data) => @_processOutput(data)

  klass::stop = ->
    @_clearNotifyTimeout()
    if @proc
      @proc.stdout.removeAllListeners()
      @proc.stderr.removeAllListeners()
      @proc.kill()
      @proc = undefined
    index = startedWatchers.indexOf(this)
    startedWatchers.splice(index, 1) if index != -1

  klass::_processOutput = (data) ->
    data = data.toString('utf8')
    if match = data.match /^Change\(\d\): (.+)$/m
      if fileName = match[1]
        path = Path.join(@path, fileName)
        @_notify(path)
