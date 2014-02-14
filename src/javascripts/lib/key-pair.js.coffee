appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
os = require 'os'
path = require 'path'

TRUE_HOME_PATH = process.env.HOME || process.env.USERPROFILE

SSH_KEYGEN_BIN_PATH = path.join(appPath, 'programs',
  "nitrous-ssh-keygen#{if os.type() == 'Windows_NT' then '.exe' else ''}")

App.KeyPair = Em.Object.extend
  privateKeyPath: null
  publicKeyPath: null
  publicKey: null
  bits: null         # e.g. 1024 bit
  fingerprint: null  # pub key fingerprint
  name: null         # pub key name
  type: null         # e.g. RSA / DSA

  exists: Em.computed.and 'privateKeyPath', 'publicKeyPath'
  noPublicKey: Em.computed.none 'publicKey'

  reset: ->
    @setProperties
      privateKeyPath: null
      publicKeyPath: null
      publicKey: null
      bits: null
      fingerprint: null
      name: null
      type: null

  scan: (cb) ->
    @reset()

    processData = (data) =>
      @setProperties(data)
      cb?()

    @_readKey 'id_dsa', (err, data) =>
      if err
        @_readKey 'id_rsa', (err, data) ->
          return cb?(new Error 'key not found') if err
          processData(data)
      else
        processData(data)

  generate: (cb) ->
    @reset()
    sshPath = path.join(TRUE_HOME_PATH, '.ssh')
    privateKeyPath = path.join(sshPath, 'id_rsa')
    publicKeyPath = privateKeyPath + '.pub'
    fs.mkdir sshPath, '0755', (err) ->
      # hide .ssh folder in windows
      if os.type() == 'Windows_NT'
        childProcess.execFile 'attrib.exe', ['+h', sshPath]

      fs.rename privateKeyPath, privateKeyPath + '.previous', (err) ->
        fs.rename publicKeyPath, publicKeyPath + '.previous', (err) ->
          passphrase = if os.type() == 'Windows_NT' then "''" else '' # empty passphrase

          args = [
            '-b', '2048' # bits
            '-t', 'rsa'  # type
            '-N', passphrase
            '-C', "nitrous-desktop@#{os.hostname().replace /\.local$/, ''}"  # name/comment
            '-f', privateKeyPath
          ]

          childProcess.execFile SSH_KEYGEN_BIN_PATH, args, {}, (err, stdout, stderr) ->
            cb?(err)

  _readKey: (keyName, cb) ->
    @reset()
    privateKeyPath = path.join(TRUE_HOME_PATH, '.ssh', keyName)
    publicKeyPath = privateKeyPath + '.pub'

    args = [
      '-l' # parse and show fingerprint
      '-f' # input file
      privateKeyPath
    ]

    childProcess.execFile SSH_KEYGEN_BIN_PATH, args, {}, (err, stdout, stderr) ->
      return cb?(err) if err
      fs.readFile publicKeyPath, encoding: 'utf8', (err, publicKey) ->
        return cb?(err) if err
        data =
          privateKeyPath: privateKeyPath
          publicKeyPath: publicKeyPath
          publicKey: publicKey

        if parsed = stdout.match(/^(\d+)\s+([0-9a-f:]+)\s+(.+)\s+\(([^\)]+)\)$/m) || stdout.match(/^(\d+)\s+([0-9a-f:]+)/m)
          data.bits = parsed[1]
          data.fingerprint = parsed[2]
          data.name = parsed[3]
          data.type = parsed[4]

        cb? null, data
