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

    newPage: (store_id, params = {}) ->
      page = new Entities.Page(params)
      page.set('store-id', store_id)
      page.url = -> "#{App.API_ROOT}/stores/#{store_id}/pages/#{@get('id')}"
      page

  App.reqres.setHandler "page:entities",
    (store_id, params) ->
      API.getPages store_id, params

  App.reqres.setHandler "page:entity",
    (params, options) ->
      if params['page_id'] == 'new'
        API.newPage params['store_id'], options
      else
        API.getPage params['store_id'], params['page_id'], options

  App.reqres.setHandler "new:page:entity",
    (params, options) ->
      API.newPage params['store_id'], params