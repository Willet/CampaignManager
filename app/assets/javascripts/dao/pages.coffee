define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getPage: (store_id, page_id, params = {}) ->
      page = new Entities.Page()
      page.url = "#{App.API_ROOT}/stores/#{store_id}/pages/#{page_id}"
      page.fetch
        reset: true
        data: params
      page

    getPages: (store_id, params = {}) ->
      pages = new Entities.PageCollection()
      pages.url = "#{App.API_ROOT}/stores/#{store_id}/pages"
      pages.fetch
        reset: true
        data: params
      pages

  App.reqres.setHandler "page:entities",
    (store_id, params) ->
      API.getPages store_id, params

  App.reqres.setHandler "page:entity",
    (store_id, page_id, params) ->
      API.getPage store_id, page_id, params
