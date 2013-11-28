App.BoxRoute = Em.Route.extend
  renderTemplate: ->
    @render 'box', outlet: 'content'
