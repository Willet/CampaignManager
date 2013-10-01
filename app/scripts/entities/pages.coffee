define [
  "entities/base"
], (Base) ->

  Entities = Entities || {};

  class Entities.Page extends Base.Model

    toJSON: ->
      json = _.clone(@attributes)
      if json['fields']
        json['fields'] = JSON.stringify(json['fields'])
      json

    parse: (data) ->
      json = data
      if json && json['fields']
        json['fields'] = $.parseJSON(json['fields'])
      json

  class Entities.PageCollection extends Base.Collection
    model: Entities.Page

    parse: (data) ->
      data['results']

  Entities
