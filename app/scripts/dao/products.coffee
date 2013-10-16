define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getProduct: (store_id, product_id, params = {}) ->
      product = new Entities.Product()
      product.url = "#{App.API_ROOT}/graph/store/#{store_id}/product/live/#{product_id}"
      product.fetch
        reset: true
        data: params
      product

    getProducts: (store_id, params = {}) ->
      products = new Entities.ProductCollection()
      products.url = "#{App.API_ROOT}/graph/store/#{store_id}/product/live"
      products.fetch
        reset: true
        data: params
      products

    getAddedPageProducts: (store_id, page_id, params = {}) ->
      products = new Entities.ProductCollection()
      products.url = "#{App.API_ROOT}/graph/store/#{store_id}/page/#{page_id}/product"
      products.fetch
        reset: true
        data: params
      products

    getProductSet: (store_id, product_ids, params = {}) ->
      products = new Entities.ProductCollection(_.map(product_ids, (id) -> {'id': id, 'store-id': store_id}))
      if products.size() > 0
        products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"
        products.fetch
          reset: false
          data: _.extend(id: product_ids, params)
      products

  App.reqres.setHandler "product:entities:set",
    (store_id, product_ids, params) ->
      API.getProductSet store_id, product_ids, params

  App.reqres.setHandler "added-to-page:page:product:entities:paged",
    (store_id, page_id, params) ->
      API.getAddedPageProducts store_id, page_id, params

  App.reqres.setHandler "page:product:entities:paged",
    (store_id, page_id, params) ->
      API.getProducts store_id, params

  App.reqres.setHandler "product:entities",
    (store_id, params) ->
      # search is possible by passing "seach-name" to
      # params
      API.getProducts store_id, params

  App.reqres.setHandler "product:entity",
    (store_id, product_id, params) ->
      API.getProduct store_id, product_id, params
