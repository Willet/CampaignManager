define [
  "app",
  "entities/base",
], (App, Base) ->

  Entities = Entities || {}

  class Entities.Store extends Base.Model

  class Entities.StoreCollection extends Base.Collection

    model: Entities.Store

    parse: (data) ->
      data['results']

  Entities
