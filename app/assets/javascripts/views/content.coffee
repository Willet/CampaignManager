define ["marionette", "backboneprojections", "models/content", "tag_it"], (Marionette, BackboneProjections, Content, TagIt) ->

  class SelectInfoBar extends Marionette.ItemView
    # model is selected collection
    template: "content_selectbar"

    events:
      "click .js-reject": "rejectSelected"
      "click .js-approve": "approveSelected"

    serializeData: ->
      return {
        size: @model.length
        models: @model.collect((m) -> m.viewJSON())
      }

    initialize: (opts) ->
      # TODO: if no items selected don't show
      @model.on("add", (=> @render()), @)
      @model.on("remove", (=> @render()), @)

    approveSelected: ->
      @model.collect((m) -> m.approve())
      foo = _.clone(@model.models)
      _.each(foo, (m) -> m.set(selected: false))

    rejectSelected: ->
      @model.collect((m) -> m.reject())
      foo = _.clone(@model.models)
      _.each(foo, (m) -> m.set(selected: false))

    onShow: ->
      # TODO: move into regionLayout on App (custom)
      $('#main').addClass("info-bar")

    onClose: ->
      # TODO: move into regionLayout on App (custom)
      $('#main').removeClass("info-bar")

  class GridItem extends Marionette.ItemView

    events:
      "click .item": "selectItem"
      "click a": "stopPropagation"

    stopPropagation: (event) ->
      event.stopPropagation()

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))

    serializeData: -> @model.viewJSON()

    template: "_content_grid_item"

    initialize: ->
      @model.on("change", (=> @render()), @)

  class ContentList extends Marionette.CollectionView

    initialize: (opts) ->
      # TODO: this does not handle order.... (collection order != current order)

    getItemView: (item) ->
      # TODO: List+Details View
      return GridItem

  class Index extends Marionette.Layout

    id: 'content-index'

    template: "content_index"

    regions:
      "list": "#list"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      @contentListView = new ContentList(
        collection: new BackboneProjections.Sorted(@model, comparator: (m) -> [m.get('selected'), m.get('id')])
      )
      @infobarView = new SelectInfoBar(model:
        new BackboneProjections.Filtered(@model, filter: (m) -> m.get('selected') == true)
      )

    onRender: (opts) ->
      @list.show(@contentListView)
      SecondFunnel.app.infobar.show(@infobarView)
      @$('#js-tag-search').tagHandler()

    onShow: (opts) ->

    onClose: ->
      SecondFunnel.app.infobar.close()

  class Show extends Marionette.Layout

    template: "content_show"

    events:
      "click .js-save": "saveContent"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

    rejectContent: (event) ->
      @model.reject()

    approveContent: (event) ->
      @model.approve()

    saveContent: (event) ->
      data = @$('form').serializeObject()
      @model.save(data)
      false

  # declare exports
  return {
    Index: Index
    Show: Show
  }


