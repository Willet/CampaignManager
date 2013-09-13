define [
  "entities/base"
], (Base) ->

  Entities = Entities || {};

  class Entities.Page extends Base.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/campaigns/#{@get('id') || ''}"

  class Entities.PageCollection extends Base.Collection
    model: Entities.Page

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@store_id}/campaigns"

    parse: (data) ->
      data['campaigns']

  Entities
