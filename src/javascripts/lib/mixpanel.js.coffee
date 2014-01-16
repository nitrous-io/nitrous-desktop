os = require 'os'
MIXPANEL_URI = 'https://api.mixpanel.com'

App.Mixpanel = klass = Em.Object.extend
  token: null
  user: null

  _userLoaded: (->
    if @get('user.username') && @get('user.email')
      @track 'Signed In'
      @setUserProperties '$set_once', first_sign_in: klass.currentTime()
  ).observes 'user.username', 'user.email'

  track: (event, properties) ->
    token = @get 'token'
    username = @get 'user.username'
    email = @get 'user.email'

    return unless token && username && email

    props =
      username: username
      email: email
      distinct_id: email
      token: token
      os_name: os.type()
      os_version: os.release()
      app_name: 'Nitrous Desktop'
      app_version: App.get 'config.appVersion'

    _.extend(props, properties ? {})

    event = switch os.type()
      when 'Darwin'
        'Mac App ' + event
      when 'Windows_NT'
        'Windows App ' + event
      else
        'App ' + event

    data =
      event: event
      properties: props

    $.ajax
      type: 'POST'
      url: MIXPANEL_URI + '/track'
      data:
        data: klass.encodeData(data)
        ip: '1'

  setUserProperties: (operation, properties) ->
    token = @get 'token'
    email = @get 'user.email'

    return unless token && email

    props = {}

    switch os.type()
      when 'Darwin'
        _.each properties, (v, k) -> props["mac_app_#{k}"] = v
      when 'Windows_NT'
        _.each properties, (v, k) -> props["windows_app_#{k}"] = v
      else
        _.each properties, (v, k) -> props["app_#{k}"] = v

    data =
      $token: token
      $distinct_id: email

    data[operation] = props

    $.ajax
      type: 'POST'
      url: MIXPANEL_URI + '/engage'
      data:
        data: klass.encodeData(data)

klass.reopenClass
  encodeData: (data) ->
    new Buffer(JSON.stringify(data), 'utf8').toString 'base64'

  currentTime: ->
    new Date().toISOString().replace(/\.\d\d\dZ$/,'')
