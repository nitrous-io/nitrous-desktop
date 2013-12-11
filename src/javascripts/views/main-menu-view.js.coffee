gui = require 'nw.gui'

App.MainMenuView = Em.View.extend
  mainMenu: null

  init: ->
    @_super.apply this, arguments
    mainMenu           = new gui.Menu(type: 'menubar')
    mainMenuAccount    = new gui.MenuItem(label: 'Account')
    accountMenu        = new gui.Menu
    accountMenuSignOut = new gui.MenuItem(label: 'Sign Out')

    accountMenuSignOut.click = ->
      App.trigger 'SignOut'

    mainMenu.append(mainMenuAccount)
    mainMenuAccount.submenu = accountMenu
    accountMenu.append(accountMenuSignOut)

    @set 'mainMenu', mainMenu

  didInsertElement: ->
    App.windowHelper.setMainMenu @get('mainMenu')
