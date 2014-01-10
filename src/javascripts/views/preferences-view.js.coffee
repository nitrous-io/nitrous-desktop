App.PreferencesView = Em.View.extend
  elementId: 'preferences-view'
  templateName: 'preferences'

  privateKeyHint: (->
    bits = @get 'controller.keyPair.bits'
    type = @get 'controller.keyPair.type'
    if bits && type
      "#{bits}-bit #{type} Key"
  ).property 'controller.keyPair.bits', 'controller.keyPair.type'

  generateKeyPairButtonDisabled:   Em.computed.or 'controller.scanning', 'controller.keyPair.exists'
  registerPublicKeyButtonDisabled: Em.computed.or 'controller.scanning', 'controller.keyPair.noPublicKey'
