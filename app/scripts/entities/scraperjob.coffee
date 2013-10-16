define [
  "entities/base",
], (Base) ->

  Entities = Entities || {}

  class Entities.ScraperJob extends Base.Model
    #
    # Fields:
    # - store-id
    # - name
    # - classname
    # - created
    # - last-modified
    # - scrape-interval
    # - script
    # - status
    #
    toJSON: ->
      data = super(arguments)
      data['name'] = data['id']
      delete data['id']
      data

    parse: (data) ->
      data['id'] = data['name']
      delete data['name']
      data


  class Entities.ProductSourceCollection extends Base.Collection
    model: Entities.ScraperJob

  return Entities