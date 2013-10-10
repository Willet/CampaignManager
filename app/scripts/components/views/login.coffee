define [
  "app"
  "marionette",
  'jquery',
], (App, Marionette, $) ->

  class Login extends Marionette.Layout
    template: "login"

    events:
      "submit form": (event) -> @login(event)

    login: (event) ->
      event.preventDefault();

      username = $(event.target).find("[name='username']").val();
      password = $(event.target).find("[name='password']").val();
      # This is the obvious way to connect login, but it is also wrong:
      # The app should have a logged in user and maintain things through that.
      # In other words, WRONG.
      $.ajax
        # replace with App.API_ROOT
        url: App.API_ROOT + '/user/login/',
        contentType: "application/json"
        dataType: 'json'
        type: 'POST'
        crossDomain: true
        data: JSON.stringify
          username: username
          password: password
        success: ->
            # Also WRONG; don't hardcode this!
            App.navigate('126/pages', trigger: true)

  Login