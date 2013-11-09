Em.ENV.RAISE_ON_DEPRECATION = true
Em.LOG_STACKTRACE_ON_DEPRECATION = true

Em.Test.adapter = Em.Test.Adapter.create
  # use mocha's simple async testing (done()) instead
  asyncStart: ->
  asyncEnd: ->

Em.Test.registerHelper 'thenCheck', (app, done, f) ->
  throw ReferenceError(done) unless done?
  wait(app).then ->
    try
      f()
      done()
    catch e
      done(e)

AIO.setupForTesting()
AIO.injectTestHelpers()

# don't wait for pending ajax requests
delete $._data(document, 'events').ajaxStart
delete $._data(document, 'events').ajaxStop

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
window.afterAll = window.after
window.beforeAll = window.before

window.expect = chai.expect

chai.Assertion.includeStack = true

window.check = (done, f) ->
  try
    f()
    done()
  catch e
    done(e)

window.spec =
  getRoute: (name) ->
    AIO.__container__.lookup("route:#{name}")

  getController: (name) ->
    AIO.__container__.lookup("controller:#{name}")

  getViewById: (id) ->
    view = Em.View.views[id]
    throw new Error "view ##{id} not found" unless view?
    view

  getMainRouter: ->
    AIO.Router.router

  getCurrentRoute: ->
    name = Em.get @getMainRouter(), 'currentHandlerInfos.lastObject.name'
    @getMainRouter().getHandler(name)

window.server = sinon.fakeServer.create()

AIO.localStorage.namespace = 'aio-spec'
gui = require 'nw.gui'
win = gui.Window.get()
win.show()

reset = ->
  window.server?.restore?()
  win.resizeTo.restore?()
  win.setResizable.restore?()
  win.moveTo.restore?()
  win.show.restore?()
  win.hide.restore?()
  gui.Window.open.restore?()
  win.close.restore?()
  AIO.localStorage.clear()

beforeEach ->
  sinon.stub win, 'resizeTo'
  sinon.stub win, 'setResizable'
  sinon.stub win, 'moveTo'
  sinon.stub win, 'show'
  sinon.stub win, 'hide'
  sinon.stub gui.Window, 'open'
  sinon.stub win, 'close'
  Em.run ->
    AIO.reset()
  window.server = sinon.fakeServer.create()

afterEach ->
  reset()

window.onload = ->
  mocha.run()
