gui = require 'nw.gui'

SIGN_IN_URI_FORMAT = '%@/users/sign_in_with_token?sign_in_token=%@&redirect_to=%@'

App.BoxController = Em.ObjectController.extend
  makeSignInURI: (path, signInToken) ->
    Em.String.fmt SIGN_IN_URI_FORMAT, [
      App.get('config.host')
      window.encodeURIComponent(signInToken)
      window.encodeURIComponent(path)
    ]

  actions:
    start: ->
      box = @get 'content'
      box.start()

    stop: ->
      box = @get 'content'
      box.stop()

    restart: ->
      box = @get 'content'
      box.restart()

    ide: ->
      App.get('currentUser').getSignInToken().then (signInToken) =>
        gui.Shell.openExternal @makeSignInURI("/app#/boxes/#{@get 'id'}/ide", signInToken)

    terminal: ->
      App.get('currentUser').getSignInToken().then (signInToken) =>
        gui.Shell.openExternal @makeSignInURI("/app#/boxes/#{@get 'id'}/terminal", signInToken)

    ssh: ->
      box = @get 'content'
      gui.Shell.openExternal "ssh://action@#{@get 'host'}:#{@get 'port'}"
