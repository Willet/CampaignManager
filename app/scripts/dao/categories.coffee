define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getCategory: (store_id, category_id, params = {}) ->
      category = new Entities.Category
        store_id: store_id
        category_id: category_id
      categories.url = "#{App.API_ROOT}/store/#{store_id}/category/#{category_id}"
      category.fetch
        reset: true
        data: params
      category

    getCategories: (store_id, params = {}) ->
      categories = new Entities.CategoryCollection
        store_id: store_id
      categories.url = "#{App.API_ROOT}/store/#{store_id}/category"
      categories.fetch
        reset: true
        data: params
      categories


  App.reqres.setHandler "categories:store",
    (store_id, params) ->
      API.getCategories store_id, params

  App.reqres.setHandler "categories:get",
    (store_id, category_id, params) ->
      API.getCategory store_id, category_id, params
