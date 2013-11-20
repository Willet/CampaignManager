define [
  'app',
  '../app',
  './name_view'
], (App, PageManager, Views) ->

  PageManager.Name ?= {}

  class PageManager.Name.Controller extends App.Controllers.Base

    initialize: ->
      page = App.routeModels.get 'page'
      store = App.routeModels.get 'store'

      layout = new Views.Name
        model: page
        store: store

      layout.on 'save', ->
        $.when(page.save()).done (data) ->
          App.navigate('/' + store.get('id') + '/pages/' + page.get('id') + '/layout', { trigger: true })

      @show layout
