appPath = require 'app-path'
childProcess = require 'child_process'
fs = require 'fs'
http = require 'http'
https = require 'https'
os = require 'os'
path = require 'path'
url = require 'url'

APPCAST_URL = "#{App.get 'config.host'}/desktop_apps/#{if App.platform.isWindows then 'windows' else 'mac'}/appcast.xml"

UPDATE_SCRIPT_PATH = path.join(appPath, 'programs',
  "nitrous-update.#{if os.type() == 'Windows_NT' then 'bat' else 'sh'}")
UPDATE_CHECK_INTERVAL = 6 * 60 * 60 * 1000  # 6 hours

App.UpdateController = klass = Em.Controller.extend
  needs: ['modal']
  checking: false
  checkFailed: false
  newVersion: null
  newVersionURL: null
  newVersionFileSize: 0
  updating: false
  updateFailed: false
  downloading: false
  downloadedBytes: 0

  beginPeriodicChecking: ->
    @check()
    window.setInterval(=>
      @check()
    , UPDATE_CHECK_INTERVAL)

  check: ->
    unless @get 'checking'
      @set 'checkFailed', false
      @set 'updateFailed', false
      @set 'checking', true

      $.ajax(
        type: 'GET'
        url: APPCAST_URL
        dataType: 'xml'
      ).done((xml, status, jqXHR) =>
        if xml instanceof Document
          if enclosure = $('item', xml).eq(0).find('enclosure').eq(0)
            version = enclosure.attr('sparkle:version')
            itemUrl = enclosure.attr('url')
            fileSize = window.parseInt enclosure.attr('length'), 10
            if version && url && fileSize && (klass.compareVersion(version, App.get('config.appVersion')) == 1)
              @setProperties
                newVersion: version
                newVersionURL: itemUrl
                newVersionFileSize: fileSize
              @presentUpdateModalDialog()
      ).fail((jqXHR, status, errMsg) =>
        @set 'checkFailed', true
      ).always =>
        @set 'checking', false

  presentUpdateModalDialog: ->
    newVersion = @get 'newVersion'
    newVersionURL = @get 'newVersionURL'
    newVersionFileSize = @get 'newVersionFileSize'

    if newVersion && newVersionURL && newVersionFileSize
      controller = this
      modalController = @get 'controllers.modal'
      modalController.setProperties
        textOne: "A new version of Nitrous Desktop is available!"
        textTwo: 'Download and install update?'
        textThree: "Nitrous Desktop #{newVersion} is now available (you have #{App.get 'config.appVersion'})."
        cancelButtonText: 'Not Now'
        okButtonText: 'Install Update'
        onCancel: ->
        onOk: =>
          Em.run.next =>
            @transitionToRoute 'preferences'
            @_performUpdate()
      Em.run.next ->
        modalController.show()

  _performUpdate: ->
    unless @get 'updating'
      @set 'updating', true
      @_downloadUpdate()

  _downloadUpdate: ->
    @set 'downloading', true
    @set 'downloadedBytes', 0

    newVersionURL = @get 'newVersionURL'
    newVersionFileSize = @get 'newVersionFileSize'
    parsedURL = url.parse(newVersionURL)

    isHTTPS = parsedURL.protocol == 'https:'

    options =
      method: 'GET'
      hostname: parsedURL.hostname
      port: parsedURL.port ? (if isHTTPS then 443 else 80)
      path: parsedURL.path
      headers:
        'user-agent': window.navigator.userAgent
        accept: '*/*'

    if isHTTPS && App.get('config.environment') == 'development'
      options.rejectUnauthorized = false

    h = if isHTTPS then https else http

    fail = =>
      @set 'updateFailed', true
      @set 'updating', false
      @set 'downloading', false

    App.utility.withDataFolder (dataPath) =>
      downloadFolderPath = path.join dataPath, 'Updates'
      fs.mkdir downloadFolderPath, =>
        fileName = parsedURL.path.split('/').slice(-1)[0]
        downloadPath = path.join downloadFolderPath, fileName
        tempDownloadPath = path.join downloadFolderPath, fileName + '.downloading'

        writeStream = fs.createWriteStream tempDownloadPath, encoding: 'binary'

        console.log "Update: Downloading #{newVersionURL} -> #{tempDownloadPath} (#{newVersionFileSize} bytes)"
        request = h.request options, (response) =>
          contentLength = window.parseInt response.headers['content-length'], 10
          console.log "Update: #{response.statusCode}, Length: #{contentLength} bytes"
          if response.statusCode != 200 || contentLength != newVersionFileSize
            console.log 'Update: Failed!'
            request.abort()
            writeStream.end()
            fail()
            return

          response.setEncoding 'binary'
          response.on 'data', (chunk) =>
            writeStream.write chunk, 'binary'
            @set 'downloadedBytes', @get('downloadedBytes') + chunk.length

          response.on 'end', =>
            writeStream.end()
            fs.rename tempDownloadPath, downloadPath, =>
              console.log 'Update: Download Finished'
              @set 'downloading', false
              @_installUpdate(downloadPath)

        request.on 'error', (err) =>
          console.log "Update: Failed! #{err.message}"
          writeStream.end()
          fail()

        request.end()

  _installUpdate: (downloadPath) ->
    if App.get('config.environment') == 'development'
      console.log 'Update: Development mode. Aborting.'
      @set 'updateFailed', true
      @set 'updating', false
      return

    executablePath = App.utility.executablePath()
    installPath = path.join executablePath, '..'

    writeTestFilePath = path.join installPath, '.nitrous-desktop-install'
    fs.writeFile writeTestFilePath, '', (err) ->
      if err
        console.log 'Update: Unable to write to install directory. Aborting.'
        @set 'updateFailed', true
        @set 'updating', false
        return

      fs.unlink(writeTestFilePath)

      args = [
        process.pid
        executablePath
        downloadPath
      ]

      options =
        cwd: installPath
        detached: true

      console.log args
      if App.platform.isWindows
        update_script_in_temp_path = path.join process.env.TEMP, 'nitrous-update.bat'
        fs.writeFileSync(update_script_in_temp_path, fs.readFileSync(UPDATE_SCRIPT_PATH))
        args.unshift '/c', 'start', 'Updating Nitrous Desktop...', '/min', update_script_in_temp_path
        childProcess.spawn 'cmd.exe', args, options
      else
        args.unshift UPDATE_SCRIPT_PATH
        childProcess.spawn '/bin/bash', args, options

      Em.run.next ->
        App.quit()

klass.reopenClass
  compareVersion: (a, b) ->
    [aMajor, aMinor, aPatch] = a.split '.'
    [bMajor, bMinor, bPatch] = b.split '.'
    aMajor.localeCompare(bMajor) ||
      aMinor.localeCompare(bMinor) ||
      aPatch.localeCompare(bPatch)
