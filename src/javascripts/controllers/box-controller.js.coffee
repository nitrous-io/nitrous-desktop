gui = require 'nw.gui'

App.BoxController = Em.ObjectController.extend
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

    syncNow: ->
      fileSync = @get 'content.fileSync'
      fileSync.performSync()

    ide: ->
      App.utility.openWebsitePath "/app#/boxes/#{@get 'id'}/ide"
      false

    terminal: ->
      App.utility.openWebsitePath "/app#/boxes/#{@get 'id'}/terminal"
      false

    ssh: ->
      box = @get 'content'
      gui.Shell.openExternal "ssh://action@#{@get 'host'}:#{@get 'port'}"
      false
