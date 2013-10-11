AIO.setupForTesting()
AIO.injectTestHelpers()

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

window.expect = chai.expect

chai.Assertion.includeStack = true

# aliases
window.server = sinon.fakeServer.create()

gui = require 'nw.gui'
win = gui.Window.get()

beforeEach ->
  sinon.stub win, 'resizeTo'
  sinon.stub win, 'setResizable'
  AIO.reset()
  window.server = sinon.fakeServer.create()

afterEach ->
  window.server.restore()
  win.resizeTo.restore()
  win.setResizable.restore()

window.onload = ->
  mocha.run()
