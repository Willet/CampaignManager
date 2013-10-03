define [
  "marionette"
], (Marionette) ->

  class Loading extends Marionette.ItemView

    template: "loading"

    initialize: (opts) ->
      defaults =
        initialized: true
        emptyMessage: "There are no items matching your criteria"
        loadingMessage: "Please wait. Loading..."
      @options = _.extend(defaults, opts)

    serializeData: ->
      {
        message: (if @options['initialized'] then @options['loadingMessage'] else @options['emptyMessage'])
      }

  return Loading