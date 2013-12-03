AIO.ShoverSocket = AIO.BaseSocket.extend
  name: 'shover'

  serverName: 'shover'

  didConnect: ->
    socket = @get('socket')
    socket.setMaxListeners(100)
    @setupHandlers(socket)

  didClose: ->
    socket = @get('socket')
    socket.removeAllListeners()

  setupHandlers: (socket) ->
    # override this method
