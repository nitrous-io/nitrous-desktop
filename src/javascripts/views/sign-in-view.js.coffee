gui = require 'nw.gui'

App.SignInView = Em.View.extend
  elementId: 'sign-in-view'
  templateName: 'sign-in'

  didEnterInvalidCredentials: (->
    @shakeWindow() if @get 'controller.invalidCredentials'
  ).observes 'controller.invalidCredentials'

  didInsertElement: ->
    @$('#username-field').focus()

  shakeWindow: ->
    win = gui.Window.get()
    x = win.x
    y = win.y

    $usernameField = @$('#username-field')

    m = (d, c) ->
      $(i: win.x).animate({ i: x + d }, step: (val) ->
        win.moveTo(Math.round(val), y)
      , duration: 100, easing: 'linear', complete: c)

    m 14, -> m -14, -> m 14, -> m -14, -> m 14, -> m -14, -> m 0, ->
      $usernameField.focus().select()
