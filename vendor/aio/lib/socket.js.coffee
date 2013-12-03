class AIO.Socket extends EventEmitter2
  constructor: (@name, @socketConnection) ->
    @emitter = new EventEmitter2
    @socketConnection.on @name, (action, args) =>
      this.emit action, args...

  destroy: ->
    @socketConnection.removeAllListeners()
    this.removeAllListeners()

  send: (event, args...) ->
    @socketConnection.send @name, event, args
