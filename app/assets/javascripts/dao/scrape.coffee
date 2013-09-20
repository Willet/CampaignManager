define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  class ScrapeDAO extends Base

  ###
  API =
    getScrape: (store_id, params = {}) ->
      scrapes = new Entities.ScrapeCollection
      scrapes.url = "#{App.apiRoot}/stores/#{store_id}/scraper"
      scrapes.fetch
        reset: true
        data: params
      scrapes
  ###
  class DAO

    actions: []

    constructor: (options) ->

    _initializeActions: ->
      _.each(@actions, (action) => @[action] = _.partial(@_action, action))

    _action: (action, params = {}) ->
      $.getJSON(@url() + "/" + action, params)

    whenFetched: (promise, fn) ->
      $.when(promise).done(fn)

  class ScrapeDAO extends DAO

    actions: [
      "update"
    ]

  API =
    getScrapes: (store_id, params = {}) ->
      data = [
        {
          url: "http://www.ae.com/web/browse/product.jsp?productId=0154_8700"
          status: 3
          title: "AE SHORT SLEEVE PLAID BUTTON DOWN"
          page_id: params.page_id
        },
        {
          url: "http://www.ae.com/web/browse/product.jsp?productId=8151_8593_567"
          status: 4
          title: "AE CAMOUFLAGE WESTERN SHIRT"
          page_id: params.page_id
        }
      ]
      new Entities.ScrapeCollection data

  App.reqres.setHandler "page:scrapes:entities",
    (store_id, page_id) ->
      API.getScrapes store_id, { page_id: page_id }

  return DAO.scrape = new ScrapeDAO()
