appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
gui = require 'nw.gui'
os = require 'os'
path = require 'path'

SIGN_IN_URI_FORMAT = '%@/users/sign_in_with_token?sign_in_token=%@&redirect_to=%@'

App.utility =
  isWindowsXP: ->
    !!(os.type() == 'Windows_NT' && os.release().match /^5\./)

  findHomeFolder: (cb) ->
    if process.env.HOME?
      cb?(process.env.HOME)
    else if @isWindowsXP()
      childProcess.execFile 'reg.exe',
        ['QUERY', 'HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders', '/v', 'Personal'],
        (err, stdout, stderr) ->
          cb?(stdout.match(/Personal\s+REG_SZ\s+([^\r\n]+)/)[1])
    else
      cb?(process.env.USERPROFILE)

  withDataFolder: (cb) ->
    switch os.type()
      when 'Windows_NT'
        dataFolder = path.join process.env.APPDATA, 'nitrous-desktop'
      when 'Darwin'
        dataFolder = path.join process.env.HOME, 'Library', 'Application Support', 'nitrous-desktop'
      else
        dataFolder = path.join process.env.HOME, '.nitrous-desktop'
    fs.mkdir dataFolder, ->
      cb?(dataFolder)

  openWebsitePath: (path) ->
    if currentUser = App.get('currentUser')
      currentUser.getSignInToken().then (signInToken) =>
        gui.Shell.openExternal Em.String.fmt(SIGN_IN_URI_FORMAT, [
          App.get('config.host')
          window.encodeURIComponent(signInToken)
          window.encodeURIComponent(path)
        ])

  executablePath: ->
    switch os.type()
      when 'Darwin'
        path.join appPath, '..', '..', '..'
      else
        null # TODO

  killAll: (procName, cb) ->
    if os.type() == 'Windows_NT'
      childProcess.execFile 'taskkill.exe', ['/IM', procName + '.exe', '/F'], {}, cb
    else
      childProcess.execFile '/usr/bin/killall', ['-9', procName], {}, cb
