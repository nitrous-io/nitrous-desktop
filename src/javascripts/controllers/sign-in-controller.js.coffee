gui = require 'nw.gui'

App.SignInController = Em.ObjectController.extend
  errorPopupVisible: false
  errorMessage: null
  invalidCredentials: false

  signInButtonDisabled: (->
    @get('isSaving') || !@get('username') || !@get('password')
  ).property 'isSaving', 'username', 'password'

  actions:
    signIn: ->
      @set 'invalidCredentials', null
      model = @get 'model'
      model.save().then =>
        App.set 'accessToken', model
        model.saveToStorage()
        @send 'signedIn'
      , (jqXHR) =>
        errorMessage = jqXHR.responseJSON?.errorDescription

        if jqXHR.status == 401
          @set 'invalidCredentials', true
        else
          @set 'errorMessage', errorMessage || 'Unable to connect to Nitrous.IO, please try again later.'
          @set 'errorPopupVisible', true
          Em.run.later(=>
            @set 'errorPopupVisible', false
          , 5000)

        @set 'isSaving', false
      false

    forgotPassword: ->
      gui.Shell.openExternal "#{App.get 'config.host'}/users/password/new"
      false

    signUp: ->
      signUpUrl = "#{App.get('config.host')}?utm_source=nitrous.io&utm_campaign=nativeapp&utm_content=#{if App.platform.isWindows then 'windows' else 'mac'}"
      gui.Shell.openExternal signUpUrl
      false

    dismissErrorPopup: ->
      @set 'errorPopupVisible', false
      false
