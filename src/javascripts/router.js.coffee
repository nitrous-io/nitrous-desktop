App.Router.map ->
  @route 'sign-in'
  @resource 'main', ->
    @resource 'box', path: '/boxes/:box_id'
    @resource 'preferences'
