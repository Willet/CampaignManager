define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getProductSource: (store_id, page_id, product_source_id, params = {}) ->
      model = new Entities.ProductSource()
      model.url = "#{App.API_ROOT}/graph/store/#{store_id}/page/#{page_id}/product-sources/#{product_source_id}"
      model.fetch
        reset: true
      model

    getProductSources: (store_id, page_id, params = {}) ->
      models = new Entities.ProductSourceCollection()
      models.url = "#{App.API_ROOT}/graph/store/#{store_id}/page/#{page_id}/product-sources"
      models.fetch
        reset: true
        data: params
      models

    createProductSource: (store_id, page_id, params = {}) ->
      model = new Entities.ProductSource(params)
      model.url = "#{App.API_ROOT}/graph/store/#{store_id}/page/#{page_id}/product-sources"
      model.save()
      model

  App.reqres.setHandler "product-sources:entities",
    (store_id, page_id) ->
      API.getProductSources store_id, page_id

  App.reqres.setHandler "product-source:entity:create",
    (store_id, page_id, data) ->
      API.createProductSource store_id, page_id, data

  App.reqres.setHandler "product-source:entity",
    (store_id, page_id, product_source_id) ->
      API.getProductSource store_id, page_id, product_source_id
