require [
  "marionette",
], (Marionette) ->

  _.extend Backbone.Marionette.View::,

    extractClassSuffix: (el, prefix) ->
      if result = el.attr('class').match(new RegExp("#{prefix}-([a-zA-Z-_]+)"))
        result[1]

    relayEvents: (view, prefix)->
      @listenTo view, "all", =>
        args = [].slice.call(arguments)
        if prefix
          args[0] = prefix + ":" + args[0]
        args.splice(1, 0, view)

        Marionette.triggerMethod.apply(@, args)

    stopRelayEvents: (view) ->
      @stopListening(view)
