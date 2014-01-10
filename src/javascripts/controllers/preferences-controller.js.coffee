App.PreferencesController = Em.Controller.extend
  userBinding: 'App.currentUser'
  keyPair: null

  scanning: false
  keyPairGenerationResult: null
  publicKeyRegistrationResult: null

  actions:
    signOut: ->
      App.trigger 'SignOut'

    rescanKeyPair: ->
      @set 'scanning', true
      @get('keyPair').scan =>
        @set 'scanning', false

    generateKeyPair: ->
      @set 'keyPairGenerationResult', null
      keyPair = @get 'keyPair'
      keyPair.generate (err) =>
        if err
          @set 'keyPairGenerationResult', 'Key Pair Generation Failed'
        else
          keyPair.scan()
          @set 'keyPairGenerationResult', 'Key Pair Successfully Generated'

    registerPublicKey: ->
      if key = @get 'keyPair.publicKey'
        @set 'publicKeyRegistrationResult', null
        record = App.PublicKey.create key: key
        record.save().then =>
          @set 'publicKeyRegistrationResult', 'Key Successfully Registered'
        , (jqXHR) =>
          if jqXHR.status == 422
            @set 'publicKeyRegistrationResult', 'Key Already Registered'
