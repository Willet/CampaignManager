require ['backbone'], (Backbone) ->

  Backbone.Model.prototype.toJSON = (opts) ->
    _.omit(@attributes, @blacklist || {})
