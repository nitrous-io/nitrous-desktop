App.BoxController = Em.ObjectController.extend
  actions:
    start: ->
      box = @get 'content'
      box.start()

    stop: ->
      box = @get 'content'
      box.stop()

    restart: ->
      box = @get 'content'
      box.restart()
