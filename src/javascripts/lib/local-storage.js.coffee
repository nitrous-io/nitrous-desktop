localStorage = window.localStorage

AIO.localStorage =
  set: (key, value) ->
    if value == null || value == undefined
      localStorage.removeItem "aio:#{key}"
    else
      localStorage.setItem "aio:#{key}", JSON.stringify(value)

  get: (key) ->
    if json = localStorage.getItem "aio:#{key}"
      JSON.parse json
