require [
  "marionette",
  "handlebars",
  "templates",
  "swag"
], (Marionette, Handlebars, JST) ->

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  # Make handlebars partials the same as JST
  Handlebars.partials = JST

  _.extend Marionette.Renderer,

    render: (template, data) ->
      # Allow no-template views
      return if template is false
      templateFunction = @getTemplate(template)
      throw "Template '#{template_name}' does not exist!" unless templateFunction
      templateFunction(data)

    getTemplate: (template) ->
      template_name = _.result(t: template, 't')
      template = JST[template_name]