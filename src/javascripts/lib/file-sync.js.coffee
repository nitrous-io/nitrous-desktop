appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
os = require 'os'
path = require 'path'

IGNORE_LIST = 'Name {.git,.svn,.hg,CVS,.DS_Store,.AppleDouble,.LSOverride,.Spotlight-V100,.Trashes}'
UNISON_BIN_PATH = path.join(appPath, 'programs',
  "nitrous-unison#{if os.type() == 'Windows_NT' then '.exe' else ''}")

nitrousPath = null

makeKey = (boxId) ->
  "box:#{boxId}:fileSync"

App.FileSync = klass = Em.Object.extend
  enabled: false
  syncing: false
  lastError: null
  boxId: null
  boxName: null
  syncURI: null
  watcher: null
  shouldIgnoreArchives: null

  init: ->
    @_super.apply this, arguments
    @enabledDidChange()

  enabledDidChange: (->
    @save()
    if @get 'enabled'
      if nitrousPath
        @_startWatching()
      else
        App.utility.findHomeFolder (home) =>
          homePath = home
          nitrousPath = path.join home, 'Nitrous'
          @_startWatching()
    else
      @_stopWatching()
  ).observes 'enabled'

  save: ->
    if boxId = @get 'boxId'
      App.localStorage.set makeKey(boxId),
        enabled: @get 'enabled'

  _startWatching: ->
    boxPath = path.join nitrousPath, @get('boxName')
    fs.mkdir nitrousPath, '0755', (err) =>
      fs.mkdir boxPath, '0755', (err) =>
        @set 'watcher', watcher = new App.Watcher(nitrousPath)
        watcher.on 'change', =>
          console.log 'change detected'
          @_performSync()
        # perform initial sync
        @_performSync ->
          watcher.start()

  _stopWatching: ->
    if watcher = @get 'watcher'
      watcher.stop()
      @set 'watcher', null

  _performSync: (cb) ->
    if @get 'syncing'
      # already syncing - enqueue one more sync
      cb?()
    else
      localPath = path.join nitrousPath, @get('boxName')
      fs.mkdir nitrousPath, '0755', (err) =>
        fs.exists localPath, (exists) =>
          remotePath = @get 'syncURI'
          args = [
            localPath
            remotePath
            '-auto' # auto accept default actions
            '-batch' # ask no questions
            '-perms=777' # sync all permissions
            '-confirmbigdel=false' # don't ask about whole replica deletes
            '-log=false' # don't log
            '-rsrc=false' # don't sync resource fork
            '-sshargs', '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -c blowfish-cbc'
            '-ignore', IGNORE_LIST
            '-prefer', remotePath
          ]

          if !exists || @get 'shouldIgnoreArchives'
            @set 'shouldIgnoreArchives', false
            args.push '-ignorearchives'

          childProcess.execFile UNISON_BIN_PATH, args, {}, (err, stdout, stderr) =>
            console.log err, stdout, stderr
            cb?()

klass._create = klass.create
klass.create = undefined

klass.reopenClass
  _cache: {}

  forBox: (box) ->
    id = box.get 'id'
    name = box.get 'name'
    syncURI = "ssh://action@#{box.get 'host'}:#{box.get 'port'}/workspace"
    @_cache[id] ||= if settings = App.localStorage.get makeKey(id)
      klass._create boxId: id, boxName: name, syncURI: syncURI, enabled: settings.enabled
    else
      klass._create boxId: id, boxName: name, syncURI: syncURI
