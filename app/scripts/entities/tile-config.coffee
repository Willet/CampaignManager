define ['app', 'entities/base', 'entities'], (App, Base, Entities) ->
  Entities = Entities || {};

  class Entities.TileConfig extends Base.Model
    relations: []

    parse: (data) ->
      if data.prioritized == 'true'
        data.prioritized = true
      else
        data.prioritized = false
      data

  class Entities.TileConfigCollection extends Base.Collection

    model: Entities.TileConfig

  Entities