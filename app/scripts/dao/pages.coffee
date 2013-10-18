define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getPage: (store_id, page_id, params = {}) ->
      page = new Entities.Page()
      page.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}"
      page.fetch
        reset: true
        data: params
      page

    getPages: (store_id, params = {}) ->
      pages = new Entities.PageCollection()
      pages.url = "#{App.API_ROOT}/store/#{store_id}/page"
      pages.fetch
        reset: true
        data: params
      pages

    newPage: (store_id, params = {}) ->
      page = new Entities.Page(params)
      page.set('store-id', store_id)
      page.url = -> "#{App.API_ROOT}/store/#{store_id}/page/#{@get('id') || ""}"
      page

    addContentToPage: (store_id, page_id, content_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/#{content_id}"
      $.ajax url, type: "PUT"

    removeContentFromPage: (store_id, page_id, content_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/#{content_id}"
      $.ajax url, type: "DELETE"

    addProductToPage: (store_id, page_id, product_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product/#{product_id}"
      $.ajax url, type: "PUT"

    removeProductFromPage: (store_id, page_id, product_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product/#{product_id}"
      $.ajax url, type: "DELETE"

  App.reqres.setHandler "page:entities",
    (store_id, options) ->
      API.getPages store_id, options

  App.reqres.setHandler "page:entity",
    (params, options) ->
      if params['page_id'] == 'new'
        API.newPage params['store_id'], options
      else
        API.getPage params['store_id'], params['page_id'], options

  App.reqres.setHandler "new:page:entity",
    (params, options) ->
      API.newPage params['store_id'], options

  App.reqres.setHandler "add_product:page:entity",
    (params, options) ->
      API.addProductToPage params['store_id'], params['page_id'], params['product_id'], options

  App.reqres.setHandler "remove_product:page:entity",
    (params, options) ->
      API.removeProductFromPage params['store_id'], params['page_id'], params['product_id'], options

  App.reqres.setHandler "add_content:page:entity",
    (params, options) ->
      API.addContentToPage params['store_id'], params['page_id'], params['content_id'], options

  App.reqres.setHandler "remove_content:page:entity",
    (params, options) ->
      API.removeContentFromPage params['store_id'], params['page_id'], params['content_id'], options
