define [
  "marionette",
  "entities",
  "../views",
], (Marionette, Entities, Views) ->

  class Views.ContentList extends Marionette.CollectionView

    template: false

    initialize: (options) ->
      @itemViewOptions = { actions: options.actions }

    getItemView: (item) ->
      Views.ContentGridItem

  class Views.ContentGridItem extends Marionette.Layout

    template: "_content_grid_item"

    regions:
      "editArea": ".edit-area"

    triggers:
      "click .js-select": "content:select-toggle"
      "click .overlay": "content:select-toggle"
      "click .js-approve": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-undecided": "content:undecided"
      "click .js-prioritize": "content:prioritize"
      "click .js-view": "content:preview"

    bindings:
      '.js-selected':
        attributes: [
          name: 'checked'
          observe: 'selected'
          onGet: (observed) ->
            if observed then true else false
        ]
      '.item':
        attributes: [
          name: 'class'
          observe: 'selected'
          onGet: (observed) ->
            if observed then "selected" else ""
        ]
      '.status':
        attributes: [
          {
            name: 'class'
            observe: ['active', 'approved']
            onGet: (observed) ->
              active = observed[0]
              approved = observed[1]
              if active && approved
                "approved"
              else if active && !approved
                "undecided"
              else
                "rejected"
          }
        ]

    initialize: (options) ->
      @actions = { actions: options.actions }

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    stopPropagation: (event) ->
      event.stopPropagation()
      false

    onRender: ->
      @backbone.stickit()
      @editArea.show(new Views.ContentEditArea(model: @model, actions: @actions))
      @relayEvents(@editArea.currentView, 'edit')

    onShow: ->

  Views