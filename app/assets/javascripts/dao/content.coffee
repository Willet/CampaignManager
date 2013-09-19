define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getContent: (store_id, content_id, params = {}) ->
      contents = new Entities.Content()
      contents.url = "#{App.API_ROOT}/stores/#{store_id}/content/#{content_id}"
      contents.fetch
        reset: true
        data: params
      contents

    getContents: (store_id, params = {}) ->
      contents = new Entities.ContentCollection()
      contents.url = "#{App.API_ROOT}/stores/#{store_id}/content"
      contents.fetch
        reset: true
        data: params
      contents

    getPagedContents: (store_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.url = "#{App.API_ROOT}/stores/#{store_id}/content"
      contents.getNextPage()
      contents

  App.reqres.setHandler "content:entities",
    (store_id, params) ->
      API.getContents store_id, params

  App.reqres.setHandler "content:entities:paged",
    (store_id, params) ->
      API.getPagedContents store_id, params

  App.reqres.setHandler "content:entity",
    (store_id, content_id, params) ->
      API.getContent store_id, content_id, params
