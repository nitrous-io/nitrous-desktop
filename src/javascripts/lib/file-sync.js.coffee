appPath = require 'app-path'
childProcess = require 'child_process'
console = window.console
fs = require 'fs'
os = require 'os'
path = require 'path'

TRUE_HOME_PATH = process.env.HOME || process.env.USERPROFILE

IGNORE_LIST = 'Name {.unison,.git,.svn,.hg,CVS,.DS_Store,.AppleDouble,.LSOverride,.Spotlight-V100,.Trashes,*.sock,*.pid,*.sw?,._*,*~}'
PROGRAMS_PATH = path.join(appPath, 'programs')
SETICON_BIN_PATH = path.join(PROGRAMS_PATH, 'seticon')
UNISON_SH_PATH   = path.join(PROGRAMS_PATH, 'nitrous-unison.sh')
UNISON_EXE_PATH  = path.join(PROGRAMS_PATH, 'nitrous-unison.exe')

FOLDER_ICON_PATH = if os.type() == 'Darwin'
  path.join(appPath, 'resources', 'images', 'NitrousFolderIcon.icns')
else
  null

RETRY_DELAY = 10000 # milliseconds

homeFolderPath = null
nitrousPath = null

makeKey = (boxId) ->
  "box:#{boxId}:fileSync"

App.FileSync = klass = Em.Object.extend
  box: null
  enabled: false
  started: false
  syncing: false
  process: null
  watcher: null
  shouldSyncAgain: false
  shouldIgnoreArchives: false
  shouldIgnoreLocks: false
  shouldRetryWithDelay: false # bool or milliseconds, if true, use default delay (RETRY_DELAY)
  transferCount: null
  lastErrorMessage: null
  retrySchedule: null

  init: ->
    @_super.apply this, arguments
    Em.run.next =>
      @_startOrStopWatching()

  state: (->
    if !@get 'enabled'
      'disabled'
    else if App.get 'offline'
      'offline'
    else if @get 'lastErrorMessage'
      'error'
    else if @get 'syncing'
      'syncing'
    else if @get 'watcher'
      'monitoring'
    else
      'disconnected'
  ).property 'enabled', 'watcher', 'syncing', 'lastErrorMessage', 'App.offline'

  stateDescription: (->
    switch @get 'state'
      when 'disabled'
        'Disabled'
      when 'offline'
        'No Internet connection'
      when 'error'
        "Error: #{@get 'lastErrorMessage'}"
      when 'syncing'
        'Syncing...'
      when 'monitoring'
        'Monitoring'
      when 'disconnected'
        'Disconnected'
  ).property 'state', 'lastErrorMessage'

  save: (->
    if boxId = @get 'box.id'
      App.localStorage.set makeKey(boxId),
        enabled: @get 'enabled'
  ).observes 'enabled'

  _updateSyncCount: (->
    if @get('syncing')
      App.incrementProperty 'syncCount'
    else
      App.decrementProperty 'syncCount'
  ).observes 'syncing'

  _startOrStopWatching: (->
    if @get('enabled') && (@get('box.state') == 'running') && App.get('online')
      if nitrousPath
        @_startWatching()
      else
        App.utility.findHomeFolder (home) =>
          homeFolderPath = home
          nitrousPath = path.join home, 'Nitrous'
          @_startWatching()
    else
      @_stopWatching()
  ).observes 'enabled', 'box.state', 'App.online'

  _startWatching: ->
    @set 'lastErrorMessage', null
    return if @get 'started'
    @set 'started', true
    boxName = @get 'box.name'
    boxPath = path.join nitrousPath, boxName
    console.log "File Sync: start watching #{boxName} - #{boxPath}"
    App.mixpanel?.track 'File Sync Started Monitoring', box_id: @get('box.id')
    fs.mkdir nitrousPath, '0755', (err) =>
      if !err && os.type() == 'Darwin'
        childProcess.execFile SETICON_BIN_PATH, [FOLDER_ICON_PATH, nitrousPath]
      fs.mkdir boxPath, '0755', (err) =>
        @set 'watcher', watcher = new App.Watcher(boxPath)
        watcher.on 'change', (changedPath) =>
          unless changedPath.indexOf(path.join(boxPath, '.unison')) == 0
            console.log "File Sync: detected change: #{changedPath}"
            @performSync()
        # perform initial sync
        @performSync =>
          watcher.start()

  _stopWatching: ->
    @set 'lastErrorMessage', null
    if retrySchedule = @get 'retrySchedule'
      Em.run.cancel(retrySchedule)
      @set 'retrySchedule', null
    if watcher = @get 'watcher'
      boxName = @get 'box.name'
      boxPath = path.join nitrousPath, boxName
      console.log "File Sync: stop watching #{boxName} - #{boxPath}"
      App.mixpanel?.track 'File Sync Stopped Monitoring', box_id: @get('box.id')
      watcher.stop()
      @set 'watcher', null
    if proc = @get 'process'
      @set 'process', null
      console.log 'File Sync: killing process'
      proc.kill()

    @set 'started', false

  performSync: (cb) ->
    @set 'lastErrorMessage', null
    @set 'transferCount', null
    @set 'shouldSyncAgain', false
    @set 'shouldRetryWithDelay', false

    if @get 'syncing'
      console.log 'File Sync: sync requested while syncing, will run sync again later'
      @set 'shouldSyncAgain', true
      cb?()
    else
      @set 'syncing', true
      box = @get 'box'
      localPath = path.join nitrousPath, box.get('name')
      fs.mkdir nitrousPath, '0755', (err) =>
        fs.exists localPath, (exists) =>
          remotePath = "#{box.get 'sshURI'}/workspace"

          devNull = if os.type() == 'Windows_NT'
            'NUL'
          else
            '/dev/null'

          sshArgs = [
            "-o UserKnownHostsFile=#{devNull}"      # ignore known hosts
            '-o StrictHostKeyChecking=no'           # no host key checking
            '-o PreferredAuthentications=publickey' # pub key authentication only
            '-c blowfish-cbc'                       # use blowfish cipher
            '-q'                                    # quiet mode
          ]

          args = [
            localPath
            remotePath
            '-ui', 'text'
            '-auto'  # auto accept default actions
            '-batch' # ask no questions
            '-perms=777'  # sync all permissions
            '-confirmbigdel=false' # don't ask about whole replica deletes
            '-log=false'  # don't log
            '-rsrc=false' # don't sync resource fork
            '-sshargs', sshArgs.join ' '
            '-ignore', IGNORE_LIST
            '-ignorecase', 'true' # case-insensitive
            '-prefer', remotePath
            '-terse' # reduce output
          ]

          # place archives file in localPath/.unison
          unisonArchivesPath = path.join(localPath, '.unison')
          env = _.clone(process.env)
          env.UNISON = unisonArchivesPath

          if os.type() == 'Windows_NT'
            env.HOME = TRUE_HOME_PATH
            env.Path = PROGRAMS_PATH + ';' + process.env.Path

          options =
            cwd: TRUE_HOME_PATH
            detached: false
            env: env

          if !exists || @get 'shouldIgnoreArchives'
            @set 'shouldIgnoreArchives', false
            args.push '-ignorearchives'

          if @get 'shouldIgnoreLocks'
            @set 'shouldIgnoreLocks', false
            args.push '-ignorelocks'

          console.log 'File Sync: syncing...'

          if os.type() == 'Windows_NT'
            fs.mkdir unisonArchivesPath, '0755', (err) ->
              childProcess.execFile 'attrib.exe', ['+h', unisonArchivesPath]
            proc = childProcess.spawn UNISON_EXE_PATH, args, options
          else
            args.unshift UNISON_SH_PATH
            proc = childProcess.spawn '/bin/bash', args, options

          @set 'process', proc
          proc.stdout.on 'data', (data) => @_processOutput(data)
          proc.stderr.on 'data', (data) => @_processOutput(data)
          proc.on 'exit', (code) => @_processDidExit(code, cb)

  _processOutput: (data) ->
    data = data.toString('utf8')
    console.log data
    if errorMessage = data.match(/[Ee]rror:\s*(.+)$/m)?[1]
      if errorMessage.indexOf('Warning: inconsistent state.') != -1 ||
         errorMessage.indexOf('on-disk archives are not identical') != -1
        @set 'lastErrorMessage', 'Inconsistent state'
        @set 'shouldIgnoreArchives', true
        @set 'shouldRetryWithDelay', 500
      else if errorMessage.indexOf('Warning: the archives are locked.') != -1
        @set 'lastErrorMessage', 'Archives are locked'
        @set 'shouldIgnoreLocks', true
        @set 'shouldRetryWithDelay', 500
      else if errorMessage.indexOf('Lost connection with the server') != -1
        @set 'lastErrorMessage', 'Connection failed'
        @set 'shouldRetryWithDelay', true
      else
        @set 'lastErrorMessage', errorMessage
        @set 'shouldRetryWithDelay', true
    if data.indexOf('Uncaught exception Sys_blocked_io') != -1
      @set 'shouldRetryWithDelay', 500
    else if transferCount = data.match(/Synchronization complete at .+ \(([\d,]+) items? transferred/)?[1]
      @set 'transferCount', window.parseInt(transferCount.replace(/,/g, ''), 10)

  _processDidExit: (code, cb) ->
    console.log "File Sync: process exited with code #{code}"
    @set 'process', null
    @set 'syncing', false

    retryDelay = @get 'shouldRetryWithDelay'

    if retryDelay || code == 3
      if typeof retryDelay == 'number'
        @_scheduleRetry(cb, retryDelay)
      else
        unless @get 'lastErrorMessage'
          @set 'lastErrorMessage', 'Unknown error'
        @_scheduleRetry(cb)
    else
      if transferCount = @get 'transferCount'
        console.log "File Sync: #{transferCount} item#{if transferCount > 1 then 's' else ''} transferred"
        App.mixpanel?.track 'File Sync Performed', box_id: @get('box.id')

      if @get('shouldSyncAgain')
        @performSync(cb)
      else
        cb?()

  _scheduleRetry: (cb, delay) ->
    if @get('retrySchedule') == null
      @set 'retrySchedule', Em.run.later(=>
        @set 'retrySchedule', null
        console.log 'File Sync: retrying...'
        @performSync(cb)
      , delay ? RETRY_DELAY)

klass._create = klass.create
klass.create = undefined

klass.reopenClass
  _cache: {}

  forBox: (box) ->
    id = box.get 'id'
    @_cache[id] ||= if settings = App.localStorage.get makeKey(id)
      klass._create box: box, enabled: settings.enabled
    else
      klass._create box: box

  killAll: (cb) ->
    childProcess.execFile '/usr/bin/killall', ['-9', 'nitrous-unison'], {}, cb

klass.killAll()
