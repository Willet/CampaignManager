#! backbone.routefilter - v0.2.0 - 2013-02-16
#* https://github.com/boazsender/backbone.routefilter
#* Copyright (c) 2013 Boaz Sender; Licensed MIT
define [
  "backbone",
  "underscore"
], (Backbone, _) ->

  # Save a reference to the original route method to be called
  # after we pave it over.
  originalRoute = Backbone.Router::route

  # Create a reusable no operation func for the case where a before
  # or after filter is not set. Backbone or Underscore should have
  # a global one of these in my opinion.
  nop = ->

  # Extend the router prototype with a default before function,
  # a default after function, and a pave over of _bindRoutes.
  _.extend Backbone.Router::,

    # Add default before filter.
    before: nop

    # Add default after filter.
    after: nop

    initialize: (options) ->
      @controller = options['controller']

    # Pave over Backbone.Router.prototype.route, the public method used
    # for adding routes to a router instance on the fly, and the
    # method which backbone uses internally for binding routes to handlers
    # on the Backbone.history singleton once it's instantiated.
    route: (route, name, callback) ->

      # If there is no callback present for this route, then set it to
      # be the name that was set in the routes property of the constructor,
      # or the name arguement of the route method invocation. This is what
      # Backbone.Router.route already does. We need to do it again,
      # because we are about to wrap the callback in a function that calls
      # the before and after filters as well as the original callback that
      # was passed in.
      callback = this[name]  unless callback

      # Create a new callback to replace the original callback that calls
      # the before and after filters as well as the original callback
      # internally.
      wrappedCallback = _.bind(->

        # Call the before filter and if it returns false, run the
        # route's original callback, and after filter. This allows
        # the user to return false from within the before filter
        # to prevent the original route callback and after
        # filter from running.
        callbackArgs = [route, _.toArray(arguments)]
        beforeCallback = undefined
        if _.isFunction(@before)

          # If the before filter is just a single function, then call
          # it with the arguments.
          beforeCallback = @before
        else if typeof @before[route] isnt "undefined"

          # otherwise, find the appropriate callback for the route name
          # and call that.
          beforeCallback = @before[route]
        else

          # otherwise, if we have a hash of routes, but no before callback
          # for this route, just use a nop function.
          beforeCallback = nop

        # If the before callback fails during its execusion (by returning)
        # false, then do not proceed with the route triggering.
        return  if beforeCallback.apply(this, callbackArgs) is false

        # If the callback exists, then call it. This means that the before
        # and after filters will be called whether or not an actual
        # callback function is supplied to handle a given route.
        callback.apply this, arguments  if callback
        afterCallback = undefined
        if _.isFunction(@after)

          # If the after filter is a single funciton, then call it with
          # the proper arguments.
          afterCallback = @after
        else if typeof @after[route] isnt "undefined"

          # otherwise if we have a hash of routes, call the appropriate
          # callback based on the route name.
          afterCallback = @after[route]
        else

          # otherwise, if we have a has of routes but no after callback
          # for this route, just use the nop function.
          afterCallback = nop

        # Call the after filter.
        afterCallback.apply this, callbackArgs
      , this)

      # Call our original route, replacing the callback that was originally
      # passed in when Backbone.Router.route was invoked with our wrapped
      # callback that calls the before and after callbacks as well as the
      # original callback.
      originalRoute.call this, route, name, wrappedCallback
