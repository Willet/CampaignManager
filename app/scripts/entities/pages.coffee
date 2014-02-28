define [
  "entities/base"
], (Base) ->

  Entities = Entities || {}

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
      json['last-modified'] = parseInt(json['last-modified'])
      json['created'] = parseInt(json['created'])
      json

    save: (attrs, options = {}) ->
      # Padding Bear Campaign Only!
      if this.get('name') == 'Paddington Bear'
        this.set('ir_base_url', 'http://tng-master.secondfunnel.com/intentrank/')

      super(attrs, options)

  class Entities.PageCollection extends Base.Collection
    model: Entities.Page

    parse: (data) ->
      data['results']

  Entities
