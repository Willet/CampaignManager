define [
  "marionette"
], (Marionette) ->

  class TitleBar extends Marionette.ItemView

    template: "shared/title_bar"

    events:
      "click #logout": (event) -> @logout(event)

    initialize: (opts) ->
      @listenTo(@model, 'sync', @render())

    logout: (event) ->
      event.preventDefault();

      # This is the obvious way to connect login, but it is also wrong:
      # The app should have a logged in user and maintain things through that.
      # In other words, WRONG.
      $.ajax
        # replace with App.API_ROOT
        url: 'http://localhost:8000/graph/v1/user/logout/',
        contentType: "application/json"
        dataType: 'json'
        type: 'POST'
        crossDomain: true

      # Again, wrong way to do things
      window.location = '/'

  return TitleBar