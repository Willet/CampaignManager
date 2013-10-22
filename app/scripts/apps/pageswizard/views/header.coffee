define [
  "marionette",
  "../views"
], (Marionette, Views) ->

  class Views.PageHeader extends Marionette.Layout

    template: "page/header"

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
      '.steps .generate':
        attributes: [
          {
            name: 'class'
            observe: 'page'
            onGet: (val, options) ->
              if val in ["view", "generate"] then "active" else ""
          }
        ]


    onRender: ->
      @stickit()

  Views
