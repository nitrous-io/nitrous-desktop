mocha.setup
  ui: 'bdd'
  globals: ['jQuery*', '__ember*', 'stats', 'failures', 'runner', 'window',
    'alert', 'setTimeout', 'setInterval', 'clearTimeout', 'clearInterval', 'onerror']
  checkLeaks: true
  timeout: 500

window.require = window.nodeRequire
window.global  = window.nodeGlobal
window.process = window.nodeProcess
window.global.location = window.location

gui = require 'nw.gui'
win = gui.Window.get()

$('#devtools').click ->
  win.showDevTools()

window.expect = chai.expect

chai.Assertion.includeStack = true

# aliases
window.server = sinon.fakeServer.create()

beforeEach ->
  window.server.restore()
  window.server = sinon.fakeServer.create()

window.onload = ->
  mocha.run()
