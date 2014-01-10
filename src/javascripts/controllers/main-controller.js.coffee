App.MainController = Em.Controller.extend
  needs: ['preferences', 'modal']
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

  checkKeyPairRequirement: ->
    controller = this
    preferencesController = @get 'controllers.preferences'
    modalController = @get 'controllers.modal'
    keyPair = preferencesController.get 'keyPair'
    keyPair.scan ->
      unless keyPair.get('exists')
        modalController.setProperties
          textOne: 'Nitrous Desktop could not find an existing SSH key pair on this computer.'
          textTwo: 'Would you like to generate one and register it with Nitrous.IO?'
          textThree: 'This is required to securely connect to your Nitrous.IO boxes.'
          cancelButtonText: 'Quit Nitrous.IO'
          okButtonText: 'Generate Key Pair'
          onCancel: ->
            App.quit()
          onOk: ->
            Em.run.next ->
              controller.transitionToRoute 'preferences'
              preferencesController.generateKeyPair (err) ->
                return if err
                preferencesController.registerPublicKey()
        Em.run.next ->
          modalController.show()
