AIO.BaseSocket = Em.Object.extend
  name: 'base'
  connection: null
  socket: null
  serverURI: null
  serverName: 'server' # used for auth token

  connect: ->
    connection = new AIO.SocketConnection "#{@get 'serverURI'}/ws", @get('serverName')
    socket = new AIO.Socket @get('name'), connection

    @setProperties
      connection: connection
      socket: socket

    connection.on 'authenticated', _.bind(@_didAuthenticate, this)
    connection.on 'close', _.bind(@didClose, this)
    connection.connect()

  _didAuthenticate: ->
    if socket = @get('socket')
      socket.send 'init', _.bind(@didConnect, this)

  didConnect: ->

  didClose: ->

  disconnect: ->
    if connection = @get 'connection'
      connection.destroy()
    @didClose()
    @setProperties
      socket: null
      connection: null

  send: ->
    if socket = @get 'socket'
      socket.apply socket, arguments
