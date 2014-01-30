define ['app', '../views', 'backbone', 'backbone.stickit'], (App, Views) ->
  'use strict'

  class Views.PublishPage extends App.Views.Layout
    template: 'page/publish'

    initialize: (opts) ->
      @store = opts.store

    events:
      'click .publish': 'onPublish'

    serializeData: ->
      page: @model.toJSON()
      url: @store.get('public-base-url')
      prodUrl: @store.get('public-base-url').replace(/(dev|test)-/g, '')
      store: @store.toJSON()

    isCopyable: ->
      # checks if CM backend could copy a page from test to production
      # if it were to try.
      test_url = @store.get('public-base-url')
      prod_url = @store.get('public-base-url').replace(/(dev|test)-/g, '')

      if prod_url == test_url
        false  # can't copy a page to/from the same destination
      else
        [test_url, prod_url]


    onPublish: ->
      # checks if page can be copied from test to production, then fire a
      # call to do so.
      if @isCopyable()
        [test_url, prod_url] = @isCopyable()
      else
        return

      if confirm(
        "Are you sure you want to copy this page from \n\n
        #{test_url}#{@model.get('url')} \n\n
        to \n\n
        #{prod_url}#{@model.get('url')} ?")

        @trigger("page:transfer", @store, @model)

    onRender: ->
      @stickit()

  Views
