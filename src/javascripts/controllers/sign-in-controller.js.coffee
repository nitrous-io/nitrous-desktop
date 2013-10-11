gui = require 'nw.gui'

AIO.SignInController = Em.ObjectController.extend
  invalidCredentials: false

  signInButtonDisabled: (->
    @get('isSaving') || !@get('username') || !@get('password')
  ).property 'isSaving', 'username', 'password'

  actions:
    signIn: ->
      @set 'invalidCredentials', null
      model = @get 'model'
      model.save().then =>
        AIO.set 'accessToken', model
        @send 'signedIn'
      , (jqXHR) =>
        errorMessage = jqXHR.responseJSON?.errorDescription

        if jqXHR.status == 401
          @set 'invalidCredentials', true
        else
          window.alert errorMessage ? 'Unable to connect to Nitrous.IO, please try again later.'

        @set 'isSaving', false

    forgotPassword: ->
      gui.Shell.openExternal "#{AIO.get 'config.host'}/users/password/new"

    signUp: ->
      gui.Shell.openExternal AIO.get('config.host')
