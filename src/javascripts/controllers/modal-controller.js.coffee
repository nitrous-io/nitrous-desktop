App.ModalController = Em.Controller.extend
  active: false

  textOne: null
  textTwo: null
  textThree: null

  cancelButtonText: null
  okButtonText: null

  show: ->
    @set 'active', true

  dismiss: ->
    @set 'active', false

  onOk: null
  onCancel: null
  afterDismiss: null

  actions:
    ok: ->
      @onOk?()
      @dismiss()

    cancel: ->
      @onCancel?()
      @dismiss()
