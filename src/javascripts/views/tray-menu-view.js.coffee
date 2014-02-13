gui = require 'nw.gui'
win = gui.Window.get()
appPath = require 'app-path'
childProcess = require 'child_process'
path = require 'path'
fs = require 'fs'
os = require 'os'

App.TrayMenuView = Em.View.extend
  elementId: 'tray-menu-view'
  tray: null
  mainMenu: null
  openWindowMenuItem: null
  openFolderMenuItem: null
  openWebMenuItem: null
  preferencesMenuItem: null
  helpMenuItem: null
  quitMenuItem: null

  init: ->
    @_super.apply this, arguments

    @setProperties
      mainMenu:            mainMenu            = new gui.Menu
      openWindowMenuItem:  openWindowMenuItem  = new gui.MenuItem(label: 'Open Nitrous Desktop...')
      openFolderMenuItem:  openFolderMenuItem  = new gui.MenuItem(label: 'Open Nitrous Folder...')
      openWebMenuItem:     openWebMenuItem     = new gui.MenuItem(label: 'Open Nitrous.IO Website...')
      preferencesMenuItem: preferencesMenuItem = new gui.MenuItem(label: 'Preferences...')
      helpMenuItem:        helpMenuItem        = new gui.MenuItem(label: 'Help')
      quitMenuItem:        quitMenuItem        = new gui.MenuItem(label: 'Quit Nitrous Desktop')

    openWindowMenuItem.click = ->
      win.show()
      win.focus()
      App.mixpanel?.track 'Opened Main Window'

    openFolderMenuItem.click = ->
      App.utility.findHomeFolder (home) =>
        nitrousFolderPath = path.join home, 'Nitrous'
        fs.mkdir nitrousFolderPath, (err) ->
          hiddenFilePath = path.join nitrousFolderPath, '.nitrous.io'
          fs.appendFile hiddenFilePath, '', (err) ->
            if os.type() == 'Windows_NT'
              childProcess.execFile 'attrib.exe', ['+h', hiddenFilePath]
            gui.Shell.showItemInFolder hiddenFilePath
      App.mixpanel?.track 'Opened Folder'

    openWebMenuItem.click = ->
      App.utility.openWebsitePath '/'
      App.mixpanel?.track 'Opened Website'

    preferencesMenuItem.click = =>
      @get('controller').transitionToRoute('preferences')
      win.show()
      win.focus()
      App.mixpanel?.track 'Opened Preferences'

    helpMenuItem.click = ->
      gui.Shell.openExternal 'http://help.nitrous.io/nitrous-desktop/'

    quitMenuItem.click = ->
      App.quit()

    @_enableOrDisableMenuItems()

    mainMenu.append(openWindowMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(openFolderMenuItem)
    mainMenu.append(openWebMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(preferencesMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(helpMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(quitMenuItem)

  didInsertElement: ->
    @show()

  willDestroyElement: ->
    @hide()

  show: ->
    @hide() if @get 'tray'

    if os.type() == 'Darwin'
      trayIconPath = path.join(appPath, 'resources', 'images', 'status-item-icon.tiff')
      trayAltIconPath = path.join(appPath, 'resources', 'images', 'status-item-icon-highlighted.tiff')
    else if os.type() == 'Windows_NT'
      trayIconPath = path.join(appPath, 'resources', 'images', 'tray-icon.png')
      trayAltIconPath = path.join(appPath, 'resources', 'images', 'tray-icon.png')

    @set 'tray', tray = new gui.Tray(icon: trayIconPath, alticon: trayAltIconPath)
    tray.menu = @get('mainMenu')

    if os.type() != 'Darwin'
      tray.on 'click', @get('openWindowMenuItem').click

  hide: ->
    if tray = @get 'tray'
      tray.remove()
      @set 'tray', null

  _enableOrDisableMenuItems: (->
    userSignedIn = App.get 'userSignedIn'
    online = App.get 'online'

    @get('openWindowMenuItem')?.enabled = userSignedIn
    @get('openFolderMenuItem')?.enabled = userSignedIn
    @get('openWebMenuItem')?.enabled = userSignedIn && online
    @get('preferencesMenuItem')?.enabled = userSignedIn
  ).observes 'App.userSignedIn', 'App.online'

  _changeTrayImage: (->
    if tray = @get 'tray'
      if os.type() == 'Darwin'
        if App.get 'online'
          if App.get('syncCount') > 0
            tray.icon = path.join(appPath, 'resources', 'images', 'status-item-icon-syncing.tiff')
            tray.alticon = path.join(appPath, 'resources', 'images', 'status-item-icon-syncing-highlighted.tiff')
          else
            tray.icon = path.join(appPath, 'resources', 'images', 'status-item-icon.tiff')
            tray.alticon = path.join(appPath, 'resources', 'images', 'status-item-icon-highlighted.tiff')
        else
          tray.icon = path.join(appPath, 'resources', 'images', 'status-item-icon-gray.tiff')
          tray.alticon = path.join(appPath, 'resources', 'images', 'status-item-icon-gray-highlighted.tiff')
      else if os.type() == 'Windows_NT'
        if App.get('syncCount') > 0
          tray.icon = path.join(appPath, 'resources', 'images', 'tray-icon-syncing.png')
          tray.alticon = path.join(appPath, 'resources', 'images', 'tray-icon-syncing.png')
        else
          tray.icon = path.join(appPath, 'resources', 'images', 'tray-icon.png')
          tray.alticon = path.join(appPath, 'resources', 'images', 'tray-icon.png')
  ).observes 'App.online', 'App.syncCount'
