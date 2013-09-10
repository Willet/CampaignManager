require [
  "marionette",
  "handlebars",
  "templates",
  "swag"
], (Marionette, Handlebars, JST) ->

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  Marionette.Renderer.render = (template, data) ->
    # Setup rendering to use JST given the template name
    try
      template = JST[_.result(t: template, 't')]
      unless template
        console.error "JST Template '#{template}' does not exist."
      return template(data)
    catch e
      console.error "error rendering template: '#{template}'", e

  Handlebars.partials = JST
