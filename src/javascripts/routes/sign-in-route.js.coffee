gui = require 'nw.gui'

AIO.SignInRoute = Em.Route.extend
  activate: ->
    win = gui.Window.get()
    win.resizeTo 320, 480 + screen.availTop
    win.setResizable false
