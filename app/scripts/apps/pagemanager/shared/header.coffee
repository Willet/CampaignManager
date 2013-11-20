define [
  'app',
  '../views'
], (App, Views) ->

  class Views.PageHeader extends App.Views.Layout

    template: "page/shared/header"

    initialize: (options) ->
      @page = options['page']
      @store = options['store']
      @listenTo(@page, 'sync', => @render())
      @listenTo(@store, 'sync', => @render())

    serializeData: ->
      return {
        page: @page.toJSON()
        store: @store.toJSON()
      }

    bindings:
      '.steps .name':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val == "name" then "active" else ""
          }
        ],
      '.steps .layout':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val == "layout" then "active" else ""
          }
        ],
      '.steps .products':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val == "products" then "active" else ""
          }
        ]
      '.steps .content':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val == "content" then "active" else ""
          }
        ]
      '.steps .publish':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val in ["view", "publish"] then "active" else ""
          }
        ]


    onRender: ->
      @stickit()

  Views