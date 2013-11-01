gui = require 'nw.gui'
screen = window.screen

AIO.MainRoute = Em.Route.extend
  beforeModel: ->
    if !AIO.get('accessToken')
      @transitionTo 'index'

  model: ->
    AIO.CurrentUser.reload()

  activate: ->
    win = gui.Window.get()
    screenWidth = (screen.availWidth - screen.availLeft)
    screenHeight = (screen.availHeight - screen.availTop)
    width = Math.min 1280, screenWidth
    height = Math.min 720, screenHeight
    x = Math.floor((screenWidth - width) / 2)
    y = Math.floor((screenHeight - height) / 2)
    win.moveTo x, y
    win.resizeTo width, height
    win.setResizable true
