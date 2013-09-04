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
      @throttledRender = _.throttle(=> @render())

    modelChangeEvent: ->
      if @model.length == 0
        @hide()
      else
        # TODO: Note this disables it
        # @show()
      @throttledRender()

    selectAll: ->
      # TODO: this is a hack
      objs = _.clone(@model.underlying.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: true)))

    unselectAll: ->
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: false)))

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

  class ListItem extends Marionette.Layout

    template: "_content_list_item"

    events:
      "click .item": "viewModal"
      "click a": "stopPropagation"
      "click .item > *": "stopPropagation"

    regions:
      "editArea": ".edit-area"

    serializeData: -> @model.viewJSON()

    initialize: ->
      @model.on("change", (=> _.throttle(_.defer(=> @render))))

    onRender: ->
      @editArea.show(new EditArea(model: @model))

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      SecondFunnel.app.modal.show(new Show(model: @model))
      event.stopPropagation()
      false

    stopPropagation: (event) ->
      event.stopPropagation()

  class GridItem extends Marionette.ItemView

    template: "_content_grid_item"

    events:
      "click .item": "selectItem"
      "click .js-view": "viewModal"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "click .js-prioritize": "prioritizeContent"
      "click .js-select": "toggleSelected"
      "click a": "stopPropagation"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))

    approveContent: (event) ->
      @model.approve()
      event.stopPropagation()
      false

    rejectContent: (event) ->
      @model.reject()
      event.stopPropagation()
      false

    prioritizeContent: (event) ->
      alert("TODO: prioritize items")
      event.stopPropagation()
      false

    initialize: ->
      @model.on("change", (=> @render()), @)

    serializeData: -> @model.viewJSON()

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      SecondFunnel.app.modal.show(new QuickView(model: @model))
      event.stopPropagation()
      false

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))

    stopPropagation: (event) ->
      event.stopPropagation()

    class QuickView extends Marionette.ItemView

      template: "_content_quick_view"

      serializeData: -> @model.viewJSON()


  class EditArea extends Marionette.ItemView

    template: "_content_edit_item"

    initialize: ->

    serializeData: -> @model.viewJSON()

    onShow: ->
      @$el.find('.js-tagged-products').tagHandler()
      @$el.find('.js-tagged-pages').tagHandler()

  class ContentList extends Marionette.CollectionView

    className: "grid-view"

    initialize: (opts) ->
      # TODO: this does not handle order.... (collection order != current order)
      @viewMode = "grid"

    setViewMode: (new_mode) ->
      @viewMode = new_mode
      @$el.removeClass("grid-view").removeClass("list-view").addClass("#{new_mode}-view")
      _.defer(=> @render())

    getItemView: (item) ->
      # TODO: List+Details View
      if @viewMode == 'grid'
        GridItem
      else
        ListItem

  class Index extends Marionette.Layout

    id: 'content-index'

    template: "content_index"

    regions:
      "list": "#list"
      "list_view_mode": "#view-mode-select"
      "editArea": ".edit-area"

    events:
      "click .js-select-all": "selectAll"
      "click .js-unselect-all": "unselectAll"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      @contentListView = new ContentList(
        collection: new BackboneProjections.Sorted(@model, comparator: (m) -> [m.get('selected'), m.get('id')])
      )
      @infobarView = new SelectInfoBar(model:
        new BackboneProjections.Filtered(@model, filter: (m) -> m.get('selected') == true)
      )
      @editView = new EditArea(model: new Content.Model("store-id": -1))
      @tabView = new ViewModeSelect(initial_state: "grid")
      @tabView.on('new-state',
        (new_state) ->
          if new_state == "grid"
            @editArea.$el.show()
          else
            @editArea.$el.hide()
          @contentListView.setViewMode(new_state)
        ,
        @
      )

    unselectAll: ->
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: false)))

    selectAll: ->
      # TODO: this is a hack
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: true)))

    onRender: (opts) ->
      @list.show(@contentListView)
      @list_view_mode.show(@tabView)
      @editArea.show(@editView)
      SecondFunnel.app.infobar.show(@infobarView)
      @$('#js-tag-search').tagHandler()

    onShow: (opts) ->

    onClose: ->
      SecondFunnel.app.infobar.close()

  class ViewModeSelect extends Marionette.ItemView

    template: "_view_mode_select"

    events:
      "click dd": "updateActive"
  
    initialize: (opts) ->
      @current_state = opts['inital_state']

    updateActive: (event) ->
      @switchActive(@extractState(event.currentTarget))

    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    currentlyActive: ->
      @$('.tabs dd.active').className.split(/\s+/)

    switchActive: (new_state) ->
      @$(".tabs .active").removeClass("active")
      @$(".tabs .js-tab-#{new_state}").addClass("active")
      @current_state = new_state
      @trigger('new-state', @current_state)

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


