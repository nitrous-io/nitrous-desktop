App.PreferencesRoute = Em.Route.extend
  renderTemplate: ->
    @render 'preferences', outlet: 'content'

  activate: ->
    @controllerFor('boxesList').set 'selectedItem', null
