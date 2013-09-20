define [
  "entities/base"
], (Base) ->

  Entities = Entities || {}

  class Entities.Scrape extends Base.Model
    #
    # Fields:
    # - URL, url entered by the user
    # - search
    # - status, indicates whether it is processing, completed, etc
    # - title, page title - used for user verification
    #
    STATUS: {
      1: "Started"
      2: "Requested"
      3: "Processing..."
      4: "Finished"
    }
    defaults:
      status: 1

    viewJSON: (opts) ->
      json = @toJSON(opts)
      json['status'] = @STATUS[json['status']]
      json

  class Entities.ScrapeCollection extends Base.Collection
    model: Entities.Scrape

  return Entities