localStorage = window.localStorage

App.localStorage =
  namespace: 'aio'

  set: (key, value) ->
    if value == null || value == undefined
      localStorage.removeItem "#{@namespace}:#{key}"
    else
      localStorage.setItem "#{@namespace}:#{key}", JSON.stringify(value)

  get: (key) ->
    if json = localStorage.getItem "#{@namespace}:#{key}"
      JSON.parse json

  clear: ->
    keysToRemove = []
    for i in [0..(localStorage.length - 1)]
      key = localStorage.key(i)
      if key && key.indexOf(@namespace + ':') == 0
        keysToRemove.push key
    for key in keysToRemove
      localStorage.removeItem key
