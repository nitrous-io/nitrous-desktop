gui = require 'nw.gui'

SIGN_IN_URI_FORMAT = '%@/users/sign_in_with_token?sign_in_token=%@&redirect_to=%@'

App.BoxController = Em.ObjectController.extend
  makeSignInURI: (path, signInToken) ->
    Em.String.fmt SIGN_IN_URI_FORMAT, [
      App.get('config.host')
      window.encodeURIComponent(signInToken)
      window.encodeURIComponent(path)
    ]

  fileSyncTogglingDisabled: false
  portForwardingTogglingDisabled: false

  actions:
    start: ->
      box = @get 'content'
      box.start()
      false

    stop: ->
      box = @get 'content'
      box.stop()
      false

    restart: ->
      box = @get 'content'
      box.restart()
      false

    ide: ->
      App.get('currentUser').getSignInToken().then (signInToken) =>
        gui.Shell.openExternal @makeSignInURI("/app#/boxes/#{@get 'id'}/ide", signInToken)
      false

    terminal: ->
      App.get('currentUser').getSignInToken().then (signInToken) =>
        gui.Shell.openExternal @makeSignInURI("/app#/boxes/#{@get 'id'}/terminal", signInToken)
      false

    ssh: ->
      box = @get 'content'
      gui.Shell.openExternal "ssh://action@#{@get 'host'}:#{@get 'port'}"
      false

    togglePortForwarding: ->
      box = @get 'content'
      box.toggleProperty 'forwardedPorts.enabled'
      @set 'portForwardingTogglingDisabled', true
      Em.run.later(=>
        @set 'portForwardingTogglingDisabled', false
      , 1000)
      false

    toggleFileSync: ->
      box = @get 'content'
      box.toggleProperty 'fileSync.enabled'
      @set 'fileSyncTogglingDisabled', true
      Em.run.later(=>
        @set 'fileSyncTogglingDisabled', false
      , 1000)
      false
