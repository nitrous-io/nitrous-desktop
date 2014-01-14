App.ApplicationRoute = Em.Route.extend
  renderTemplate: ->
    @_super()
    @render 'modal', into: 'application', outlet: 'modal', controller: 'modal'
