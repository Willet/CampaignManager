define ["marionette", "backboneprojections", "models/content", "tag_it"], (Marionette, BackboneProjections, Content, TagIt) ->

  class SelectInfoBar extends Marionette.ItemView
    # model is selected collection
    template: "content_selectbar"

    events:
      "click .js-reject": "rejectSelected"
      "click .js-approve": "approveSelected"
      "click .js-unselect-all": "unselectAll"
      "click .js-select-all": "selectAll"

    serializeData: ->
      return {
        size: @model.length
        models: @model.collect((m) -> m.viewJSON())
      }

    initialize: (opts) ->
      # TODO: if no items selected don't show
      @model.on("add remove", @modelChangeEvent, @)

    modelChangeEvent: ->
      if @model.length == 0
        @hide()
      else
        @show()
      @render()

    unselectAll: ->
      objs = _.clone(@model.models)
      _.each(objs, (m) -> m.set(selected: false))
      console.log @model

    selectAll: ->
      # TODO: this is a hack
      objs = _.clone(@model.underlying.models)
      _.each(objs, (m) -> m.set(selected: true))

    approveSelected: ->
      @model.collect((m) -> m.approve())
      @unselectAll()

    rejectSelected: ->
      @model.collect((m) -> m.reject())
      @unselectAll()

    onShow: ->
      # TODO: move into regionLayout on App (custom)
      @modelChangeEvent

    hide: ->
      $('#info-bar').addClass("hide")
      $('#main').removeClass("info-bar")
    show: ->
      $('#info-bar').removeClass("hide")
      $('#main').addClass("info-bar")

    onClose: ->
      # TODO: move into regionLayout on App (custom)
      $('#main').removeClass("info-bar")

  class GridItem extends Marionette.ItemView

    events:
      "click .item": "selectItem"
      "click .view": "viewModal"
      "click a": "stopPropagation"

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      SecondFunnel.app.modal.show(new Show(model: @model))
      event.stopPropagation()
      false

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


