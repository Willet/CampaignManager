define ['app', 'marionette', 'jquery'], (App, Marionette, $) ->
  'use strict'

  class Login extends Marionette.Layout
    template: 'login'
    events:
      'submit form': 'login'
    regions:
      'loginFail': '.login-fail'

    login: (event) ->
      event.preventDefault()

      username = $(event.target).find('[name=\'username\']').val()
      password = $(event.target).find('[name=\'password\']').val()

      App.request('user:login', username, password)
        .fail =>
          @$(@loginFail.el).show()

    onRender: =>
      @$(@loginFail.el).hide()

      setTimeout ->  # whenever the DOM shows this element
        @$('#login-email').focus()
      , 100

  Login
