appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
os = require 'os'
path = require 'path'
console = window.console

IGNORE_LIST = 'Name {.git,.svn,.hg,CVS,.DS_Store,.AppleDouble,.LSOverride,.Spotlight-V100,.Trashes}'
UNISON_BIN_PATH = path.join(appPath, 'programs',
  "nitrous-unison#{if os.type() == 'Windows_NT' then '.exe' else ''}")

RETRY_DELAY = 10000 # milliseconds

homePath = null
nitrousPath = null

makeKey = (boxId) ->
  "box:#{boxId}:fileSync"

App.FileSync = klass = Em.Object.extend
  enabled: false
  togglingDisabled: false
  syncing: false
  lastError: null
  boxId: null
  boxName: null
  syncURI: null
  watcher: null
  shouldSyncAgain: false
  shouldIgnoreArchives: false
  retrySchedule: null

  init: ->
    @_super.apply this, arguments
    Em.run.next =>
      @_enabledDidChange()

  _enabledDidChange: (->
    @set 'togglingDisabled', true
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

  _reenableToggling: ->
    Em.run.later(=>
      @set 'togglingDisabled', false
    , 1000)

  _startWatching: ->
    boxPath = path.join nitrousPath, @get('boxName')
    console.log "File Sync: start watching #{boxPath}"
    fs.mkdir nitrousPath, '0755', (err) =>
      fs.mkdir boxPath, '0755', (err) =>
        @set 'watcher', watcher = new App.Watcher(nitrousPath)
        watcher.on 'change', =>
          @_performSync()
        # perform initial sync
        @_performSync =>
          watcher.start()
          @_reenableToggling()

  _stopWatching: ->
    if retrySchedule = @get 'retrySchedule'
      Em.run.cancel(retrySchedule)
      @set 'retrySchedule', null
    if watcher = @get 'watcher'
      boxName = @get 'boxName'
      boxPath = path.join nitrousPath, @get('boxName')
      console.log "File Sync: stop watching #{boxPath}"
      watcher.stop()
      @set 'watcher', null
    @_reenableToggling()

  _performSync: (cb) ->
    if @get 'syncing'
      console.log 'File Sync: already syncing, will run sync again'
      @set 'shouldSyncAgain', true
      cb?()
    else
      @set 'syncing', true
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

          options =
            cwd: homePath

          if !exists || @get 'shouldIgnoreArchives'
            @set 'shouldIgnoreArchives', false
            args.push '-ignorearchives'

          console.log 'File Sync: syncing...'
          childProcess.execFile UNISON_BIN_PATH, args, options, (err, stdout, stderr) =>
            @_processOutput(err, stdout, stderr, cb)

  _processOutput: (err, stdout, stderr, cb) ->
    console.log "#{stdout.trim()}\n#{stderr.trim()}"
    console.log 'File Sync: process finished'
    errorMessage = stderr.match(/[Ee]rror:\s*(.+)$/m)?[1]
    if err
      console.log "File Sync: error! code: #{err.code}, killed: #{err.killed}, signal: #{err.signal}"
      if errorMessage &&
         (errorMessage.indexOf('Warning: inconsistent state.') != -1 ||
          errorMessage.indexOf('on-disk archives are not identical') != -1)
        @set 'shouldIgnoreArchives', true
      console.log 'File Sync: schedule retry'
      @_scheduleRetry()
    else
      if transferCount = stderr.match(/Synchronization complete at .+ \(([\d,]+) items? transferred/)?[1]
        transferCount = window.parseInt(transferCount.replace(/,/g, ''), 10)
        console.log "File Sync: #{transferCount} item#{if transferCount > 1 then 's' else ''} transferred"
        # TODO: notify completion
        # TODO: mixpanel
    @set 'syncing', false
    cb?()
    if @get 'shouldSyncAgain'
      @set 'shouldSyncAgain', false
      @_performSync()

  _scheduleRetry: ->
    if @get('retrySchedule') == null
      @set 'retrySchedule', Em.run.later(=>
        @set 'retrySchedule', null
        console.log 'File Sync: retrying...'
        @_performSync()
      , RETRY_DELAY)

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
