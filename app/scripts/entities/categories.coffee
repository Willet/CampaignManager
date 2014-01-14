define [
  "app",
  "entities/base",
], (App, Base) ->

  Entities = Entities || {}

  class Entities.Category extends Base.Model
    initialize: (store_id, category_id) ->
      @store_id = store_id
      @category_id = category_id

  class Entities.CategoryCollection extends Base.Collection

    model: Entities.Category

    initialize: (models, store_id) ->
      @store_id = store_id

    parse: (data) ->
      data['results']

  Entities
