define [
  "app",
  "entities/base",
], (App, Base) ->

  Entities = Entities || {}

  class Entities.Category extends Base.Model

  class Entities.CategoryCollection extends Base.Collection

    model: Entities.Category

    parse: (data) ->
      data['results']

  Entities
