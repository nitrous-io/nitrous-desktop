AIO.Router.map ->
  @route 'sign-in'
  @resource 'main', ->
    @resource 'box', path: '/boxes/:box_id'
