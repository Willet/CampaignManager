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
      page: @page.toJSON()
      store: @store.toJSON()

    events:
      'click .steps li a': ->
        # persist changes to the page object when the user changes step
        @page.save()

    bindings:
      '.steps .name':  # given this thing,
        attributes: [
          {
            name: 'class'  # change the attribute of this thing, i.e. $('.steps .name').prop('class')
            observe: 'page'  # if @(this variable), i.e. this.page
            onGet: (val, options) ->  # i.e. $(...).prop('class', what this returns)
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

  Views
