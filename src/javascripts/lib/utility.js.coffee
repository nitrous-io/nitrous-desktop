gui = require 'nw.gui'
path = require 'path'
os = require 'os'
childProcess = require 'child_process'

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

  openWebsitePath: (path) ->
    if currentUser = App.get('currentUser')
      currentUser.getSignInToken().then (signInToken) =>
        gui.Shell.openExternal Em.String.fmt(SIGN_IN_URI_FORMAT, [
          App.get('config.host')
          window.encodeURIComponent(signInToken)
          window.encodeURIComponent(path)
        ])
