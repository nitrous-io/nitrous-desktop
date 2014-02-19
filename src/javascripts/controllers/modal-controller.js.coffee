App.ModalController = Em.Controller.extend
  active: false

  textOne: null
  textTwo: null
  textThree: null
  cancelButtonText: null
  okButtonText: null
  onOk: null
  onCancel: null
  afterDismiss: null

  reset: ->
    @setProperties
      textOne: null
      textTwo: null
      textThree: null
      cancelButtonText: null
      okButtonText: null
      onOk: null
      onCancel: null
      afterDismiss: null

  show: ->
    @set 'active', true

  dismiss: ->
    @set 'active', false

  actions:
    ok: ->
      @onOk?()
      @dismiss()

    cancel: ->
      @onCancel?()
      @dismiss()
