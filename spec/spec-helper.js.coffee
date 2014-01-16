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

App.setupForTesting()
App.injectTestHelpers()
App.set 'config.mixpanelToken', null

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
    App.__container__.lookup("route:#{name}")

  getController: (name) ->
    App.__container__.lookup("controller:#{name}")

  getViewById: (id) ->
    view = Em.View.views[id]
    throw new Error "view ##{id} not found" unless view?
    view

  getMainRouter: ->
    App.Router.router

  getCurrentRoute: ->
    name = Em.get @getMainRouter(), 'currentHandlerInfos.lastObject.name'
    @getMainRouter().getHandler(name)

App.localStorage.namespace = 'app-spec'
gui = require 'nw.gui'
win = gui.Window.get()
win.show()

stub = ->
  sinon.stub win, 'resizeTo'
  sinon.stub win, 'setResizable'
  sinon.stub win, 'setAlwaysOnTop'
  sinon.stub win, 'moveTo'
  sinon.stub win, 'show'
  sinon.stub win, 'hide'
  sinon.stub gui.Window, 'open'
  sinon.stub win, 'close'

unstub = ->
  win.resizeTo.restore?()
  win.setResizable.restore?()
  win.setAlwaysOnTop.restore?()
  win.moveTo.restore?()
  win.show.restore?()
  win.hide.restore?()
  gui.Window.open.restore?()
  win.close.restore?()
  App.localStorage.clear()

beforeEach ->
  window.server?.restore?()
  window.server = sinon.fakeServer.create()
  unstub()
  stub()
  Em.run ->
    App.reset()

afterEach ->
  unstub()

window.onload = ->
  mocha.run()

if window.SockJS
  window.OriginalSockJS = window.SockJS
  class window.FakeSockJS extends window.OriginalSockJS
    constructor: ->
  window.SockJS = window.FakeSockJS
