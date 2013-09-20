define [
  "entities/base"
], (Base) ->

  Entities = Entities || {};

  class Entities.Page extends Base.Model

  class Entities.PageCollection extends Base.Collection
    model: Entities.Page

    parse: (data) ->
      data['campaigns']

  Entities
