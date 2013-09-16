require [
  "marionette",
], (Marionette) ->

  _.extend Backbone.Marionette.View::,

    relayEvents: (view, prefix)->
      @listenTo view, "all", =>
        args = [].slice.call(arguments)
        if prefix
          args[0] = prefix + ":" + args[0]
        args.splice(1, 0, view)

        Marionette.triggerMethod.apply(@, args)
