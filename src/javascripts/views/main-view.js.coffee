gui = require 'nw.gui'

App.MainView = Em.View.extend
  elementId: 'main-view'
  templateName: 'main'

  didInsertElement: ->
    win = gui.Window.get()
    win.focus()
