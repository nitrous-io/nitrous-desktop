App.MainController = Em.Controller.extend
  needs: ['preferences', 'publicKeysList', 'modal']
  modelBinding: 'App.currentUser'
  shoverSocket: null

  didObtainCurrentUser: (->
    if @get('model.id')
      @connectToShover() if @get('model.id')
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

  # checks whether system ssh key pair exists
  checkKeyPairRequirement: (cb) ->
    controller = this
    preferencesController = @get 'controllers.preferences'
    modalController = @get 'controllers.modal'
    keyPair = preferencesController.get 'keyPair'
    keyPair.scan ->
      if keyPair.get('exists')
        cb?()
      else
        modalController.setProperties
          textOne: 'Nitrous Desktop could not find an existing SSH key pair on this computer.'
          textTwo: 'Generate one and register it with Nitrous.IO?'
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
          afterDismiss: ->
            cb?()
        Em.run.next ->
          modalController.show()

  # checks whether system public key is registered
  checkPublicKeyRequirement: (cb) ->
    controller = this
    publicKeysListController = @get 'controllers.publicKeysList'
    preferencesController = @get 'controllers.preferences'
    modalController = @get 'controllers.modal'
    keyPair = preferencesController.get 'keyPair'
    if fingerprint = keyPair.get 'fingerprint'
      if publicKeysListController.findBy 'md5Fingerprint', fingerprint
        cb?()
      else
        modalController.setProperties
          textOne: "This computer's SSH public key is not yet registered with Nitrous.IO."
          textTwo: 'Register it with Nitrous.IO?'
          textThree: 'This is required to securely connect to your Nitrous.IO boxes.'
          cancelButtonText: 'Quit Nitrous.IO'
          okButtonText: 'Register Public Key'
          onCancel: ->
            App.quit()
          onOk: ->
            Em.run.next ->
              controller.transitionToRoute 'preferences'
              preferencesController.registerPublicKey()
          afterDismiss: ->
            cb?()
        Em.run.next ->
          modalController.show()
