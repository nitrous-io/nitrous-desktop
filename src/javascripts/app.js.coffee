#= require ./lib/utility
#= require_tree ./lib
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./components
#= require_tree ../templates
#= require_tree ./routes
#= require_self
#= require router

# all classes except router are loaded
App.trigger 'AppDidLoad'
