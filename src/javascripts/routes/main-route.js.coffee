gui = require 'nw.gui'
screen = window.screen

AIO.MainRoute = Em.Route.extend
  beforeModel: ->
    if !AIO.get('accessToken')
      @transitionTo 'index'

  model: ->
    AIO.CurrentUser.reload()

  renderTemplate: ->
    @_super()
    @render 'boxesList',      into: 'main', outlet: 'boxesList',      controller: 'boxesList'
    @render 'publicKeysList', into: 'main', outlet: 'publicKeysList', controller: 'publicKeysList'

  setupController: (controller, model) ->
    @_super(controller, model)
    AIO.BoxTemplate.find()
    AIO.Region.find()
    @controllerFor('boxesList').set 'model', AIO.Box.find()
    @controllerFor('publicKeysList').set 'model', AIO.PublicKey.find()

  activate: ->
    win = gui.Window.get()
    win.hide()
    AIO.windowHelper.resizeAndMoveToCenter(800, 450)
    win.setResizable true
    win.show()

  actions:
    boxSelected: (box) ->
      @transitionTo 'box', box
