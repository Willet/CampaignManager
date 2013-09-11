require [
  "marionette",
  "handlebars",
  "templates",
  "swag"
], (Marionette, Handlebars, JST) ->

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  Marionette.Renderer.render = (template_name, data) ->
    # Setup rendering to use JST given the template name
    try
      template_name = _.result(t: template_name, 't')
      template = JST[template_name]
      unless template
        console.error "JST Template '#{template_name}' does not exist."
      else
        return template(data)
    catch e
      console.error "error rendering template: '#{template_name}'"
      throw e

  Handlebars.partials = JST
