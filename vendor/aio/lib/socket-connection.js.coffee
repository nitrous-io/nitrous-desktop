class AIO.SocketConnection extends EventEmitter2
  timeout: 50 # seconds, must be greater than heartbeat interval (25 seconds)
  timeoutCheckInterval: 5 # seconds, check for timeout every 5 seconds
  lastHeartbeat: null

  constructor: (@serverURI, @serverName) ->
    @nextCallbackId = 0
    @callbacks = []
    @retries = 0

  connect: ->
    @sock = new SockJS @serverURI, null, protocols_whitelist: ['websocket']
    @sock.onopen      = _.bind(@_didOpen, this)
    @sock.onmessage   = _.bind(@_didReceiveMessage, this)
    @sock.onclose     = _.bind(@_didClose, this)
    @sock.onheartbeat = _.bind(@_didReceiveHeartbeat, this)

  registerCallback: (callback) ->
    callbackId = @nextCallbackId++
    @callbacks[callbackId] = callback
    callbackId

  invokeCallback: (callbackId, args) ->
    if callback = @callbacks[callbackId]
      @callbacks[callbackId] = null
      callback args...

  destroy: ->
    @callbacks = []
    this.removeAllListeners()
    this._destroySock()

  _destroySock: ->
    if @sock
      @sock.onopen = null
      @sock.onmessage = null
      @sock.onclose = null
      @sock.close()
      @sock = null

  _didOpen: (event) ->
    @retries = 0
    this._authenticate()
    this._startTimeoutCheck()
    this.emit 'open', event

  _authenticate: ->
    AIO.authToken.obtain @serverName, (err, authToken) =>
      return if err
      this.send 'global', 'auth', [authToken, (=>
        this.emit 'authenticated'
      )]

  _didReceiveMessage: (event) ->
    message = event.data
    try
      message = JSON.parse message
    if message instanceof Array
      [namespace, event, args] = message
      if _.isString(namespace) && _.isString(event)
        if namespace == 'global' && event == 'callback'
          [callbackId, callbackArgs] = args
          this.invokeCallback callbackId, callbackArgs
        else
          this.emit namespace, event, args
          return
    this.emit 'message', message

  _didReceiveHeartbeat: (event) ->
    @lastHeartbeat = +new Date

  _didClose: (event) ->
    this.emit 'close', event
    this._stopTimeoutCheck()
    this._retry()

  _startTimeoutCheck: ->
    this._stopTimeoutCheck()
    @lastHeartbeat = +new Date
    @timeoutCheck = window.setInterval(=>
      if (@lastHeartbeat + @timeout * 1000) <= +new Date
        @sock?.close()
    , @timeoutCheckInterval * 1000)

  _stopTimeoutCheck: ->
    if @timeoutCheck?
      window.clearInterval @timeoutCheck
      @timeoutCheck = null

  _retry: ->
    @retries += 1
    this._destroySock()
    wait = if @retries <= 5
      1000
    else if @retries <= 10
      5000
    else if @retries > 10
      10000
    window.setTimeout(=>
      this.connect()
    , wait)

  send: (name, event, args) ->
    if @sock
      if _.isFunction(_.last args)
        callback = args.pop()
        callbackId = this.registerCallback callback
        @sock.send JSON.stringify([name, event, args, callbackId])
      else
        @sock.send JSON.stringify([name, event, args])
