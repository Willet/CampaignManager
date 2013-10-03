define [
  "marionette"
], (Marionette) ->

  class MainNav extends Marionette.ItemView

    template: "shared/nav"

    initialize: (opts) ->
      @model.get('store')?.on("sync", => @render())

    serializeData: ->
      json = {}
      json['store'] = @model.get('store').toJSON() if @model.get('store')
      json['page'] = @model.get('page')
      json

  return MainNav