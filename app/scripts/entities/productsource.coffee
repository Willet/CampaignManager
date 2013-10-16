define [
  "entities/base",
  "./scraperjob"
], (Base) ->

  Entities = Entities || {}

  class Entities.ProductSource extends Base.Model
    #
    # Fields:
    # - id
    # - page-id, page who owns the product source
    # - last-modified, when record was last modified
    #
    # one-of:
    # - url, url entered by the user to scrape
    # - product-id, id of the product they searched
    # - category-id, id of the category they searched
    #
    # Relations:
    # - scraper-job-name (optional), ID of the scraper job
    #
    # Commonly fetched relations
    # - (optional) product
    # - (optional) category
    # - (optional) scraper-job
    #

  class Entities.ProductSourceCollection extends Base.Collection
    model: Entities.ProductSource

  return Entities