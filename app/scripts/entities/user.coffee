define ['app', 'entities/base', 'entities/products', 'underscore'], (App, Base, Entities, _) ->
  Entities = Entities || {}

  # @returns {Promise}
  class Entities.User extends Base.Model
      login: (username, password) ->
        that = @

        # TODO: Need to address security concerns of sending PW as plaintext
        login = $.ajax
          url: this.url + '/login/'  # trailing slash required for some reason
          contentType: 'application/json'
          dataType: 'json'
          type: 'POST'
          crossDomain: true
          data: JSON.stringify
            username: username
            password: password

        login.done (response) ->
          that.set(response)

          store = _.first(that.get('stores'))

          # Is this where this belongs?
          # Why do we need to do this? Why can't we just use App?
          # Why is App not what I expect it to be?
          window.App.user = that
          # Should we create a store instance?
          window.App.store = store

          $.getJSON(App.API_ROOT + '/store/?slug=' + that.get('username'))
            .done((data) ->
              if data.results.length
                # store id, e.g. 126
                store = data.results[0]
                if (store.old_id)  # prioritize the old_id attribute
                  navigateUrl = data.results[0].old_id + '/pages'
                else
                  navigateUrl = data.results[0].id + '/pages'
              else
                # Default to store 38 (Gap) for now...
                navigateUrl = '38/pages'

              App.navigate(navigateUrl, trigger: true)
            )

        # allow more deferreds to be set
        login.promise()

      logout: ->
        dfr = $.ajax
          url: @url + '/logout/'
          contentType: 'application/json'
          dataType: 'json'
          type: 'POST'
        dfr.promise()

  Entities
