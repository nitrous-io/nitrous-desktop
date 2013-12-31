gui = require 'nw.gui'
win = gui.Window.get()

if App.get('config.environment') == 'development'
  $('#debug').show()
  $('#debug .devtools').click ->
    win.showDevTools()
    false
  $('#debug .reload').click ->
    App.cleanUp ->
      win.reloadIgnoringCache()
    false
  $('#debug .spec').click ->
    gui.Window.open location.href.replace(/index\.html.*/, 'spec/spec.html'),
      position: 'center'
      width: 1024
      height: 768
      toolbar: false
    false
