gui = require 'nw.gui'
win = gui.Window.get()
appPath = require 'app-path'
path = require 'path'
fs = require 'fs'

App.TrayMenu = Em.View.extend
  tray: null
  mainMenu: null

  init: ->
    @_super.apply this, arguments

    mainMenu           = new gui.Menu

    openWindowMenuItem = new gui.MenuItem(label: 'Open Nitrous Desktop...')

    openFolderMenuItem = new gui.MenuItem(label: 'Open Nitrous.IO Folder...')
    openWebMenuItem    = new gui.MenuItem(label: 'Open Nitrous.IO Website...')

    signOutMenuItem    = new gui.MenuItem(label: 'Sign Out')

    quitMenuItem       = new gui.MenuItem(label: 'Quit Nitrous Desktop')

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

    mainMenu.append(openWindowMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(openFolderMenuItem)
    mainMenu.append(openWebMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(signOutMenuItem)
    mainMenu.append(new gui.MenuItem type: 'separator')
    mainMenu.append(quitMenuItem)
    @set 'mainMenu', mainMenu
    @show()

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
