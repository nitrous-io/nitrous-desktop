prepareError = (message, jqXHR) ->
  err = new Error(message)
  err.jqXHR = jqXHR
  err

AIO.authToken =
  authTokenServerURI: null
  requestHeaders: null

  obtain: (name, callback) ->
    authTokenServerURI = @authTokenServerURI || ''
    requestHeaders = @requestHeaders || {}

    $.ajax(
      type: 'GET'
      url: "#{authTokenServerURI}/auth_token/#{name}"
      dataType: 'json'
      headers: requestHeaders
    ).done((data, status, jqXHR) ->
      if data.auth_token?
        callback null, data.auth_token
      else
        callback prepareError('auth_token not found', jqXHR)
    ).fail (jqXHR, status, errMsg) ->
      callback prepareError(errMsg, jqXHR)
