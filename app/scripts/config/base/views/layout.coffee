define ['app', 'marionette'], (App, Marionette) ->
  "use strict"

  ###
  base layout
  ###
  class App.Views.Layout extends Marionette.Layout

    # regions
    # triggers
    # events

    # ???
    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    serializeData: ->
      @model?.viewJSON() || {}


  ###
  Supposedly one that shows multiple pages; paging is done by the controller.
  ###
  class App.Views.PagedLayout extends App.Views.Layout

    nextPage: ->
      @$('.loading').show()
      @trigger "fetch:next-page"
      false

    onShow: ->
      @on "fetch:next-page:complete", =>
        @$('.loading').hide()
