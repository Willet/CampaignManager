require ["secondfunnel", "backbone", "app", "marionette", "handlebars", "swag", "jquery", "underscore", "foundation", "templates"], (SecondFunnel, Backbone, App, Marionette, Handlebars, Swag, $, _, Foundation, JST) ->

  # Handle Unauthorized (Redirect to login, etc...)
  redirectToLogin = ->
    locationhref = "/login"
    if (location.hash && location.hash.length > 0)
      locationhref += "?r=" + location.hash.substring(1)
    location.href = locationhref

  $(document).ajaxError((event, xhr) ->
    if (xhr.status == 401)
      redirectToLogin()
  )

  # TODO: REMOVE (already in config)
  Backbone.Model.prototype.toJSON = (opts) ->
    _.omit(@attributes, @blacklist || {})

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  $().ready(-> App.start())
