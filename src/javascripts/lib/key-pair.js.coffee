appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
os = require 'os'
path = require 'path'

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
    App.utility.findHomeFolder (home) ->
      privateKeyPath = path.join(home, '.ssh', 'id_rsa')
      publicKeyPath = privateKeyPath + '.pub'
      fs.rename privateKeyPath, privateKeyPath + '.previous', (err) ->
        fs.rename publicKeyPath, publicKeyPath + '.previous', (err) ->
          args = [
            '-b', '2048' # bits
            '-t', 'rsa'  # type
            '-N', ''     # passphrase: none
            '-C', "nitrous-desktop@#{os.hostname().replace /\.local$/, ''}"  # name/comment
            '-f', privateKeyPath
          ]

          childProcess.execFile SSH_KEYGEN_BIN_PATH, args, {}, (err, stdout, stderr) ->
            cb?(err)

  _readKey: (keyName, cb) ->
    @reset()
    App.utility.findHomeFolder (home) ->
      privateKeyPath = path.join(home, '.ssh', keyName)
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
          keyData = stdout.match /^(\d+)\s+([0-9a-f:]+)\s+([^\s]+)\s+\(([^\)]+)\)$/m
          cb? null,
            privateKeyPath: privateKeyPath
            publicKeyPath: publicKeyPath
            publicKey: publicKey
            bits: keyData[1]
            fingerprint: keyData[2]
            name: keyData[3]
            type: keyData[4]
