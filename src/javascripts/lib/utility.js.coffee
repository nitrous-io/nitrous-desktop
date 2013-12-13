path = require 'path'
os = require 'os'
childProcess = require 'child_process'

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
