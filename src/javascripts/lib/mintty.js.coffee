return unless App.platform.isWindows

appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
path = require 'path'

TRUE_HOME_PATH = process.env.HOME || process.env.USERPROFILE

SSH_BIN_PATH = path.join(appPath, 'programs', 'nitrous-ssh.exe')
MINTTY_BIN_PATH = path.join(appPath, 'programs', 'mintty.exe')
unless fs.existsSync(MINTTY_BIN_PATH)
  MINTTY_BIN_PATH = path.join(process.execPath, '..', 'tools', 'mintty.exe')

SSH_ICON_PATH = path.join(appPath, 'resources', 'images', 'ssh-icon.ico')

App.mintty =
  ssh: (user, host, port, title) ->
    args = [
      '--option', 'Locale=en_US'
      '--option', 'Charset=UTF-8'
      '--option', 'Term=xterm-256color'
      '--icon', SSH_ICON_PATH
      '--exec', SSH_BIN_PATH
      '-o', 'UserKnownHostsFile=NUL'
      '-o', 'StrictHostKeyChecking=no'
      '-o', 'PreferredAuthentications=publickey'
      '-o', 'LogLevel=FATAL'
      '-c', 'blowfish-cbc'
      '-p', port
      "#{user}@#{host}"
    ]

    if title
      args.unshift '--title', title

    env = _.clone(process.env)

    if App.platform.isWindows
      env.HOME = TRUE_HOME_PATH

    options =
      cwd: TRUE_HOME_PATH
      env: env

    childProcess.execFile MINTTY_BIN_PATH, args, options
