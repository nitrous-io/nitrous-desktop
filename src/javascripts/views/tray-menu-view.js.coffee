gui = require 'nw.gui'
win = gui.Window.get()
appPath = require 'app-path'
path = require 'path'
fs = require 'fs'

App.TrayMenuView = Em.View.extend
  elementId: 'tray-menu-view'
  tray: null
  mainMenu: null
  openWindowMenuItem: null
  openFolderMenuItem: null
  openWebMenuItem: null
  signOutMenuItem: null
  quitMenuItem: null

  init: ->
    @_super.apply this, arguments

    @setProperties
      mainMenu:           mainMenu           = new gui.Menu
      openWindowMenuItem: openWindowMenuItem = new gui.MenuItem(label: 'Open Nitrous Desktop...')
      openFolderMenuItem: openFolderMenuItem = new gui.MenuItem(label: 'Open Nitrous Folder...')
      openWebMenuItem:    openWebMenuItem    = new gui.MenuItem(label: 'Open Nitrous.IO Website...')
      signOutMenuItem:    signOutMenuItem    = new gui.MenuItem(label: 'Sign Out')
      quitMenuItem:       quitMenuItem       = new gui.MenuItem(label: 'Quit Nitrous Desktop')

    openWindowMenuItem.click = ->
      win.show()
      win.focus()

    openFolderMenuItem.click = ->
      App.utility.findHomeFolder (home) =>
        nitrousFolderPath = path.join home, 'Nitrous'
        fs.mkdir nitrousFolderPath, (err) ->
          hiddenFilePath = path.join nitrousFolderPath, '.nitrous.io'
          fs.appendFile hiddenFilePath, '', (err) ->
            gui.Shell.showItemInFolder hiddenFilePath

    openWebMenuItem.click = ->
      App.utility.openWebsitePath '/'

    signOutMenuItem.click = ->
      App.trigger 'SignOut'

    quitMenuItem.click = ->
      App.quit()

    @_enableOrDisableMenuItems()

    mainMenu.append(openWindowMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(openFolderMenuItem)
    mainMenu.append(openWebMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(signOutMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(quitMenuItem)

  didInsertElement: ->
    @show()

  willDestroyElement: ->
    @hide()

  show: ->
    @hide() if @get 'tray'

    trayIconPath = path.join(appPath, 'resources', 'images', 'status-item-icon.png')
    trayAltIconPath = path.join(appPath, 'resources', 'images', 'status-item-icon-highlighted.png')

    @set 'tray', tray = new gui.Tray(icon: trayIconPath, alticon: trayAltIconPath)
    tray.menu = @get('mainMenu')

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
    @get('signOutMenuItem')?.enabled = userSignedIn
  ).observes 'App.userSignedIn', 'App.online'
