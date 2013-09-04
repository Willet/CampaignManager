require ["marionette", "templates", "handlebars"], (Marionette, JST, Handlebars) ->

  Marionette.Renderer.render = (template, data) ->
    # Setup rendering to use JST given the template name
    try
      return JST[_.result(t: template, 't')](data)
    catch e
      console.error "JST Template '#{template}' does not exist."
      throw e

  Handlebars.partials = JST
