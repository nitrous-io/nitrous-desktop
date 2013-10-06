#= require jquery/jquery-2.0.3
#= require handlebars
#= require ember
#= require ember-model/ember-model-0.0.10
#= require_self
#= require aio

window.gui = require 'nw.gui'

window.NitrousIO = Em.Application.extend
  rootElement: "#app"
  online: navigator.onLine
  offline: Em.computed.not 'online'

window.AIO = NitrousIO.create()

$(window).on 'online', ->
  AIO.set 'online', true

$(window).on 'offline', ->
  AIO.set 'online', false

win = gui.Window.get()
$html = $('html')

win.on 'focus', ->
 $html.removeClass 'blurred'

win.on 'blur', ->
  $html.addClass 'blurred'
