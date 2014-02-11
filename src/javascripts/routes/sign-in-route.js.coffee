gui = require 'nw.gui'
win = gui.Window.get()

App.SignInRoute = Em.Route.extend
  model: ->
    App.AccessToken.create clientId: App.get('config.clientId'), clientSecret: App.get('config.clientSecret')

  activate: ->
    win.hide()
    App.windowHelper.resizeAndMoveToCenter(320, 480)
    win.setResizable false
    win.setAlwaysOnTop(true)
    win.show()

  deactivate: ->
    win.setAlwaysOnTop(false)

  actions:
    signedIn: ->
      @transitionTo 'main'
