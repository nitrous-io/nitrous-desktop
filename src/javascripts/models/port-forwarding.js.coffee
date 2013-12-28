#= require ./forwarded-port

appPath = require 'app-path'
childProcess = require 'child_process'
console = window.console
os = require 'os'
path = require 'path'

SSH_BIN_PATH = path.join(appPath, 'programs',
  "nitrous-ssh#{if os.type() == 'Windows_NT' then '.exe' else ''}")

RETRY_DELAY = 10000 # milliseconds

makeKey = (boxId) ->
  "box:#{boxId}:portForwarding"

App.PortForwarding = klass = Em.ArrayProxy.extend Em.SortableMixin,
  content: Em.computed -> Em.A()
  sortProperties: ['port']
  box: null
  enabled: false
  connected: false
  process: null
  lastErrorMessage: null
  retrySchedule: null

  init: ->
    @_super.apply this, arguments
    Em.run.next =>
      @_startOrStopPortForwarding()

  sortFunction: (x, y) ->
    return 0 if x == y
    if x < y then -1 else 1

  forwardedPorts: (->
    @get('arrangedContent').map (forwardedPort) ->
      forwardedPort.get 'port'
  ).property 'arrangedContent.[]'

  connecting: (->
    @get('process')? && !@get('connected')
  ).property 'connected', 'process'

  state: (->
    if !@get 'enabled'
      'disabled'
    else if @get 'lastErrorMessage'
      'error'
    else if @get 'connected'
      'connected'
    else if @get 'connecting'
      'connecting'
    else
      'disconnected'
  ).property 'enabled', 'connected', 'connecting', 'lastErrorMessage'

  stateDescription: (->
    switch @get 'state'
      when 'disabled'
        'Disabled'
      when 'error'
        "Error: #{@get 'lastErrorMessage'}"
      when 'connected'
        'Connected'
      when 'connecting'
        'Connecting...'
      when 'disconnected'
        'Disconnected'
  ).property 'state', 'lastErrorMessage'

  add: (input) ->
    list = @get 'content'
    port = window.parseInt input, 10
    if port > 0 && port < 65536 && !list.findBy('content', port)
      item = App.ForwardedPort.create port: port
      list.pushObject item

  remove: (obj) ->
    @removeObject(obj)

  save: (->
    if boxId = @get 'box.id'
      App.localStorage.set makeKey(boxId),
        enabled: @get 'enabled'
        ports: @get 'forwardedPorts'
  ).observes 'enabled'

  _forwardedPortsDidChange: (->
    @save()
    if @get('process')
      @_scheduleRetry(1000)
  ).observes 'arrangedContent.[]'

  _startOrStopPortForwarding: (->
    if @get('enabled') && @get('box.state') == 'running'
      @_startPortForwarding()
    else
      @_stopPortForwarding()
  ).observes 'enabled', 'box.state'

  _startPortForwarding: ->
    @set 'lastErrorMessage', null
    box = @get 'box'
    console.log "Port Forwarding: start #{box.get 'name'}"

    args = [
      '-v' # verbose mode - print messages about progress
      '-N' # do not execute remote command
      '-g' # allow LAN connections
      '-o', 'TCPKeepAlive=yes'                   # use tcp keep alive
      '-o', 'ServerAliveInterval=60'             # send keep alive packet to server every 60 sec
      '-o', 'UserKnownHostsFile=/dev/null'       # don't write known hosts
      '-o', 'StrictHostKeyChecking=no'           # no host key checking
      '-o', 'PreferredAuthentications=publickey' # pub key authentication only
      '-o', 'ExitOnForwardFailure=yes'           # exit on forward failure
      '-c', 'blowfish-cbc'                       # use blowfish cipher
      '-p', box.get 'port'
      "action@#{box.get 'host'}"
    ]

    @get('forwardedPorts').forEach (port) ->
      args = args.concat ['-L', "#{port}/localhost/#{port}"]

    console.log SSH_BIN_PATH, args.join(' ')
    console.log 'Port Forwarding: connecting...'
    @set 'process', process = childProcess.spawn(SSH_BIN_PATH, args, {})
    process.stdout.on 'data', (data) => @_processOutput(data)
    process.stderr.on 'data', (data) => @_processOutput(data)
    process.on 'exit', =>
      @set 'process', null
      @set 'connected', false

  _stopPortForwarding: ->
    @set 'lastErrorMessage', null
    process = @get 'process'
    retrySchedule = @get 'retrySchedule'
    if process || retrySchedule
      console.log "Port Forwarding: stop #{@get 'box.name'}"
      if retrySchedule
        Em.run.cancel(retrySchedule)
        @set 'retrySchedule', null
      if process
        @_killProcess()

  _restartPortForwarding: ->
    @_stopPortForwarding()
    @_startPortForwarding()

  _killProcess: ->
    @set 'connected', false
    if process = @get 'process'
      console.log 'Port Forwarding: killing process'
      @set 'process', null
      process.kill()

  _scheduleRetry: (delay) ->
    @_killProcess()
    if @get('retrySchedule') == null
      @set 'retrySchedule', Em.run.later(=>
        @set 'retrySchedule', null
        console.log 'Port Forwarding: retrying...'
        @_startPortForwarding()
      , delay ? RETRY_DELAY)

  _processOutput: (data) ->
    data = data.toString('utf8')
    console.log data
    if match = data.match /^debug1: Entering interactive session\./m
      @set 'connected', true
    else
      if match = data.match /^channel_setup_fwd_listener: cannot listen to port: (\d+)/m
        @set 'lastErrorMessage', "Port #{match[1]} is already in use"
      else if match = data.match /^Permission denied \(publickey\)/m
        @set 'lastErrorMessage', 'Could not authenticate'
      else if match = data.match /: Could not resolve hostname/m
        @set 'lastErrorMessage', 'Could not resolve hostname'
      else if match = data.match /Host is down/m
        @set 'lastErrorMessage', 'Could not reach host'
      else if match = data.match /: Operation timed out/m
        @set 'lastErrorMessage', 'Connection timed out'
      else if match = data.match /: Connection refused/m
        @set 'lastErrorMessage', 'Connection refused'
      else if match = data.match /Timeout, server/m
        @set 'lastErrorMessage', 'Connection timed out'
      else if match = data.match /^Write failed: Broken pipe/m
        @set 'lastErrorMessage', 'Connection lost'

      if match
        @_scheduleRetry()

klass._create = klass.create
klass.create = undefined

klass.reopenClass
  _cache: {}

  forBox: (box) ->
    id = box.get 'id'
    @_cache[id] ||= if settings = App.localStorage.get makeKey(id)
      ports = (settings.ports || []).map (p) ->
        App.ForwardedPort.create port: p
      klass._create box: box, content: ports, enabled: settings.enabled
    else
      klass._create box: box
