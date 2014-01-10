gui = require 'nw.gui'
win = gui.Window.get()

App.ModalView = Em.View.extend
  elementId: 'modal-view'
  templateName: 'modal'

  _showOrHide: (->
    if $el = @$()
      controller = @get 'controller'
      if controller.get 'active'
        win.show()
        win.focus()
        $el.show()
        Em.run.next ->
          $el.addClass 'in'
      else
        $el.removeClass 'in'
        Em.run.later(->
          $el.hide()
          controller.afterDismiss?()
        , 201)
  ).observes 'controller.active'
