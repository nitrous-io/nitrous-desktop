App.MainController = Em.Controller.extend
  modelBinding: 'App.currentUser'
  shoverSocket: null

  didObtainCurrentUser: (->
    @connectToShover()
  ).observes 'model.id'

  connectToShover: ->
    @set 'shoverSocket', shoverSocket = AIO.ShoverSocket.create(serverURIBinding: 'App.config.shoverServerURI')

    AIO.authToken.authTokenServerURI = App.get('config.apiURI')
    AIO.authToken.requestHeaders = { Authorization: "Bearer #{App.get 'accessToken.token'}" }

    shoverSocket.setupHandlers = (socket) ->
      socket.on 'aio:box_updated', (json) ->
        data = json[App.Box.rootKey]
        App.Box.find(data.id).load(data.id, data)

    shoverSocket.connect()
