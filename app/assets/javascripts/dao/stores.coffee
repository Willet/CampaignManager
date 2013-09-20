define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getStore: (store_id, params = {}) ->
      store = new Entities.Store()
      store.url = "#{App.API_ROOT}/stores/#{store_id}"
      store.fetch
        reset: true
        data: params
      store

    getStores: (params = {}) ->
      stores = new Entities.StoreCollection()
      stores.url = "#{App.API_ROOT}/stores"
      stores.fetch
        reset: true
        data: params
      stores

  if App.mode == "local"
    API =
      getStore: (store_id, params = {}) ->
        return new Entities.Store { id: store_id, name: "Second Funnel" }
      getStores: (params = {}) ->
        return new Entities.StoreCollection @getStore(126, params)


  App.reqres.setHandler "store:entities",
    (params) ->
      API.getStores params

  App.reqres.setHandler "store:entity",
    (store_id, params) ->
      API.getStore store_id, params
