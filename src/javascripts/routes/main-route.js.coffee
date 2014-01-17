gui = require 'nw.gui'
screen = window.screen

App.MainRoute = Em.Route.extend
  beforeModel: ->
    if !App.get('accessToken')
      @transitionTo 'index'

  model: ->
    App.CurrentUser.reload()

  renderTemplate: ->
    @_super()
    @render 'boxesList',      into: 'main', outlet: 'boxesList',      controller: 'boxesList'
    @render 'publicKeysList', into: 'main', outlet: 'publicKeysList', controller: 'publicKeysList'

  setupController: (controller, model) ->
    @_super(controller, model)
    App.BoxTemplate.find()
    App.Region.find()
    @controllerFor('preferences').set 'keyPair', App.KeyPair.create()
    controller.checkKeyPairRequirement =>
      boxesListController = @controllerFor 'boxesList'
      boxesListController.set 'model', boxes = App.Box.find()
      boxes.one 'didLoad', (boxes) ->
        boxesListController.selectFirstItem()
      @controllerFor('publicKeysList').set 'model', publicKeys = App.PublicKey.find()
      publicKeys.one 'didLoad', =>
        controller.checkPublicKeyRequirement =>
          @controllerFor('update').check()

  activate: ->
    win = gui.Window.get()
    win.hide()
    App.windowHelper.resizeAndMoveToCenter(800, 500)
    win.setResizable true
    win.show()

  actions:
    boxSelected: (box) ->
      @transitionTo 'box', box
