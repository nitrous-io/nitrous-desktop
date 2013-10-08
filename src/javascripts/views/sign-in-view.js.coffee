gui = require 'nw.gui'

AIO.SignInView = Em.View.extend
  elementId: 'sign-in-view'

  didClickForgotPassword: ->
    gui.Shell.openExternal 'about:blank'

  didClickSignUp: ->
    gui.Shell.openExternal 'about:blank'
