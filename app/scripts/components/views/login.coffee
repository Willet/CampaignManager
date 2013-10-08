define [
  "marionette"
], (Marionette) ->

  class Login extends Marionette.Layout
    template: "login"

    events:
      "click input[type=submit]": (event)-> @login(event)

    login: (event) ->
      event.preventDefault();
      alert('test');

  Login
