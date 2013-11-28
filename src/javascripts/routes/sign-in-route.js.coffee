gui = require 'nw.gui'
screen = window.screen

App.SignInRoute = Em.Route.extend
  model: ->
    App.AccessToken.create clientId: App.get('config.clientId'), clientSecret: App.get('config.clientSecret')

  activate: ->
    win = gui.Window.get()
    win.hide()
    App.windowHelper.resizeAndMoveToCenter(320 + screen.availLeft, 480 + screen.availTop)
    win.setResizable false
    win.show()

  actions:
    signedIn: ->
      @transitionTo 'main'
