gui = require 'nw.gui'

AIO.SignInRoute = Em.Route.extend
  model: ->
    AIO.AccessToken.create clientId: AIO.get('config.clientId'), clientSecret: AIO.get('config.clientSecret')

  activate: ->
    win = gui.Window.get()
    win.resizeTo 320, 480 + screen.availTop
    win.setResizable false

  events: ->
    signedIn: ->
      @transitionTo 'main'
