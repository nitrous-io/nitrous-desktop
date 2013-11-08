AIO.BoxView = Em.View.extend
  elementId: 'box-view'
  templateName: 'box'

  stackImage: (->
    runtime = @get 'context.boxTemplate.runtime'
    runtime = switch runtime
      when 'rails'
        'ruby'
      when 'django'
        'python'
      else runtime
    "resources/images/#{runtime}.png"
  ).property 'context.boxTemplate.runtime'
