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
      if (result = element.className.match(/js-tab-([a-zA-Z-_]+)/))
        return result[1]
      null

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    serializeData: ->
      @model?.viewJSON() || {}

    # support stickit bindings: call super() if subclass has its own onRender
    onRender: ->
      if @model and @bindings
        @stickit()


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


  ###
  Layouts with sorting and filtering options.
  ###
  class App.Views.SortableLayout extends App.Views.Layout
    triggers:
      "change #js-filter-sort-order": "change:filter"

    # returns all (default) filters except the ones with blank values
    extractFilter: (filter = {}) ->

      # all undefined if control not in view
      filter['source'] = @$('#js-filter-content-source').val()
      filter['type'] = @$('#js-filter-type').val()
      filter['tags'] = @$('#js-filter-tags').val()
      filter['order'] = @$('#js-filter-sort-order').val()

      sortKey = @$('#js-filter-sort-order').val()
      sortDirection = @$('#js-filter-sort-order option:selected').data('direction')
      if sortKey
        filter[sortKey] = sortDirection

      _.each(_.keys(filter), (key) ->
        delete filter[key] if filter[key] == null || !/\S/.test(filter[key])
      )

      filter
