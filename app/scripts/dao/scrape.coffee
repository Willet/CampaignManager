define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getScrapes: (store_id, params = {}) ->
      stores = new Entities.StoreCollection()
      stores.url = "#{App.API_ROOT}/store/#{store_id}/product-sources"
      stores.fetch
        reset: true
        data: params
      stores

  App.reqres.setHandler "page:scrapes:entities",
    (store_id, page_id) ->
      API.getScrapes store_id, { page_id: page_id }

  { }