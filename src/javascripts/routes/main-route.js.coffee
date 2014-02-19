gui = require 'nw.gui'
win = gui.Window.get()
screen = window.screen

App.MainRoute = Em.Route.extend
  beforeModel: ->
    if !App.get('accessToken')
      @transitionTo 'index'

  renderTemplate: ->
    @_super()
    @render 'boxesList',      into: 'main', outlet: 'boxesList',      controller: 'boxesList'
    @render 'publicKeysList', into: 'main', outlet: 'publicKeysList', controller: 'publicKeysList'

  setupController: (controller, model) ->
    @_super.apply this, arguments
    @loadModels(controller)

  loadModels: (controller) ->
    userId = App.get 'accessToken.resourceOwnerId'
    App.CurrentUser.fetch(userId).then((currentUser) =>
      App.set 'currentUser', currentUser
      controller.connectToShover()
      App.BoxTemplate.find()
      App.Region.find()
      @controllerFor('preferences').set 'keyPair', App.KeyPair.create()
      controller.checkKeyPairRequirement =>
        @controllerFor('publicKeysList').set 'model', publicKeys = App.PublicKey.find()
        publicKeys.one 'didLoad', =>
          controller.checkPublicKeyRequirement =>
            @controllerFor('update').beginPeriodicChecking()
            boxesListController = @controllerFor 'boxesList'
            boxesListController.set 'model', boxes = App.Box.find()
            boxes.one 'didLoad', ->
              boxesListController.selectFirstItem()
    , (jqXHR) =>
      Em.run.later(=>
        @loadModels(controller)
      , 5000)
      jqXHR
    ).then ->
      win.show()

  activate: ->
    win.hide()
    App.windowHelper.resizeAndMoveToCenter(800, 500)
    win.setResizable true

  actions:
    boxSelected: (box) ->
      @transitionTo 'box', box
