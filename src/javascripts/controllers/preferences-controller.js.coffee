App.PreferencesController = Em.Controller.extend
  needs: ['update']
  userBinding: 'App.currentUser'
  keyPair: null
  updateChecker: null

  scanning: false
  keyPairGenerationResult: null
  publicKeyRegistrationResult: null

  generateKeyPair: (cb) ->
    @set 'keyPairGenerationResult', null
    keyPair = @get 'keyPair'
    keyPair.generate (err) =>
      if err
        @set 'keyPairGenerationResult', 'Key Pair Generation Failed'
        cb?(err)
      else
        @set 'keyPairGenerationResult', 'Key Pair Successfully Generated'
        keyPair.scan ->
          cb?()
        App.mixpanel?.track 'Generated SSH Key Pair'


  registerPublicKey: ->
    if key = @get 'keyPair.publicKey'
      @set 'publicKeyRegistrationResult', null
      record = App.PublicKey.create key: key
      record.save().then =>
        @set 'publicKeyRegistrationResult', 'Key Successfully Registered'
        App.mixpanel?.track 'Registered SSH Key Pair'
      , (jqXHR) =>
        if jqXHR.status == 422
          @set 'publicKeyRegistrationResult', 'Key Already Registered'

  actions:
    signOut: ->
      App.trigger 'SignOut'

    checkForUpdate: ->
      @get('controllers.update').check()

    rescanKeyPair: ->
      @set 'scanning', true
      @get('keyPair').scan =>
        @set 'scanning', false

    generateKeyPair: ->
      @generateKeyPair()

    registerPublicKey: ->
      @registerPublicKey()
