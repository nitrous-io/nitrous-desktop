gui = require 'nw.gui'
screen = window.screen

AIO.windowHelper =
  resizeAndMoveToCenter: (width, height) ->
    win = gui.Window.get()
    screenWidth = (screen.availWidth - screen.availLeft)
    screenHeight = (screen.availHeight - screen.availTop)
    x = Math.max(Math.floor((screenWidth - width) / 2), screen.availLeft)
    y = Math.max(Math.floor((screenHeight - height) / 2), screen.availTop)
    win.moveTo x, y
    win.resizeTo width, height
