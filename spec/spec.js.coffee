#= require application
#= require_self
#= require mocha/mocha-1.13.0
#= require chai/chai-1.8.0
#= require sinon/sinon-1.7.3
#= require sinon-chai/sinon-chai-2.4.0
#= require chai-jquery/chai-jquery-1.1.2
#= require spec-helper
#= require_tree .

gui = require 'nw.gui'
win = gui.Window.get()

$('#debug .devtools').click ->
  win.showDevTools()

$('#debug .reload').click ->
  win.reloadIgnoringCache()

window.nodeRequire = window.require
window.nodeGlobal = window.global
window.nodeProcess = window.process
window.require = undefined
window.global = undefined
window.process = undefined
