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
    screenWidth = (screen.availWidth - screen.availLeft)
    screenHeight = (screen.availHeight - screen.availTop)
    width = Math.min 800, screenWidth
    height = Math.min 450, screenHeight
    x = Math.floor((screenWidth - width) / 2) + screen.availLeft
    y = Math.floor((screenHeight - height) / 2) + screen.availTop
    win.moveTo x, y
    win.resizeTo width, height
    win.setResizable true
    win.show()

  actions:
    boxSelected: (box) ->
      @transitionTo 'box', box
