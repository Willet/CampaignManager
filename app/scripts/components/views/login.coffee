define [
  "marionette",
  'jquery',
], (Marionette, $) ->

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
        url: 'http://localhost:8000/graph/v1/user/login/',
        contentType: "application/json"
        dataType: 'json'
        type: 'POST'
        crossDomain: true
        data: JSON.stringify
          username: username
          password: password

  Login
