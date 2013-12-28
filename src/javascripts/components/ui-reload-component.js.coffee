App.UiReloadComponent = Em.Component.extend
  classNames: ['ui-reload']
  classNameBindings: ['reloading']
  reloading: false
  tagName: 'button'

  content: null

  click: ->
    @set 'reloading', true
    if content = @get 'content'
      content.reload().then =>
        @set 'reloading', false
      , =>
        @set 'reloading', false
