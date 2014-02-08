gui = require 'nw.gui'

App.BoxController = Em.ObjectController.extend
  fileSyncTogglingDisabled: false
  portForwardingTogglingDisabled: false

  actions:
    start: ->
      box = @get 'content'
      box.start()
      App.mixpanel?.track 'Started Box', box_id: box.get('id')
      false

    stop: ->
      box = @get 'content'
      box.stop()
      App.mixpanel?.track 'Shut Down Box', box_id: box.get('id')
      false

    restart: ->
      box = @get 'content'
      box.restart()
      App.mixpanel?.track 'Restarted Box', box_id: box.get('id')
      false

    syncNow: ->
      box = @get 'content'
      fileSync = box.get 'fileSync'
      fileSync.performSync()
      App.mixpanel?.track 'Forced File Sync', box_id: box.get('id')
      false

    ide: ->
      box = @get 'content'
      boxId = box.get 'id'
      App.utility.openWebsitePath "/app#/boxes/#{boxId}/ide"
      App.mixpanel?.track 'Opened Web IDE', box_id: boxId
      false

    terminal: ->
      box = @get 'content'
      boxId = box.get 'id'
      App.utility.openWebsitePath "/app#/boxes/#{boxId}/terminal"
      App.mixpanel?.track 'Opened Web Terminal', box_id: boxId
      false

    ssh: ->
      box = @get 'content'
      host = @get 'host'
      port = @get 'port'
      if App.platform.isWindows
        App.mintty.ssh 'action', host, port, "#{box.get('name')} | Nitrous Desktop"
      else
        gui.Shell.openExternal "ssh://action@#{host}:#{port}"

      App.mixpanel?.track 'Opened Shell', box_id: box.get('id')
      false

    fileSyncHelp: ->
      gui.Shell.openExternal 'http://help.nitrous.io/nitrous-desktop/#file_sync'
      false

    portForwardingHelp: ->
      gui.Shell.openExternal 'http://help.nitrous.io/nitrous-desktop/#port_forwarding'
      false
