define [
  "app",
  "entities/base",
], (App, Base) ->

  Entities = Entities || {}

  class Entities.Store extends Base.Model

  class Entities.StoreCollection extends Base.Collection

    model: Entities.Store

    parse: (data) ->
      if data.results.old_id
        data.results.id = data.results.old_id
      data.results

  Entities
