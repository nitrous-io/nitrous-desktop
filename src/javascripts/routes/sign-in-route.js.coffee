gui = require 'nw.gui'
screen = window.screen

AIO.SignInRoute = Em.Route.extend
  model: ->
    AIO.AccessToken.create clientId: AIO.get('config.clientId'), clientSecret: AIO.get('config.clientSecret')

  activate: ->
    win = gui.Window.get()
    win.hide()
    AIO.windowHelper.resizeAndMoveToCenter(320 + screen.availLeft, 480 + screen.availTop)
    win.setResizable false
    win.show()

  actions:
    signedIn: ->
      @transitionTo 'main'
