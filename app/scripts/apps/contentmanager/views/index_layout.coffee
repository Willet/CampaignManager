define [
  'app',
  'entities',
  '../views',
  'jquery'
], (App, Entities, Views, $) ->

  class Views.ContentIndexLayout extends App.Views.Layout

    template: 'content/index'

    regions:
      "list": "#list"
      "listControls": "#list-controls"
      "multiedit": ".edit-area"

    events:
      "click dd": "updateActive"
      "change #sort-order": "updateSortOrder"
      "change #filter-page": "filterPage"
      "change #filter-content-type": "filterContentType"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    triggers:
      "click .js-select-all": "content:select-all"
      "click .js-unselect-all": "content:unselect-all"

    initialize: (opts) ->
      @current_state = opts['initial_state']

    filterContentType: (event) ->
      @trigger("change:filter-content-type", @$(event.currentTarget).val())

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    updateSortOrder: (event) ->
      @trigger("change:sort-order", @$(event.currentTarget).val())

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    nextPage: ->
      @$('.loading').show()
      @trigger("fetch:next-page")
      false

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
      @$('#list').removeClass("grid-view").removeClass("list-view").addClass("#{new_state}-view")

    onRender: (opts) ->

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)
      @$('.loading').hide()
      @on "fetch:next-page:complete", =>
        @$('.loading').hide()

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  Views
