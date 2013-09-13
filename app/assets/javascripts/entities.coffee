Entities = window.Entities || {}

define "entities", [
  "entities/products",
  "entities/content",
  "entities/pages",
  "entities/stores"
], (Products, Content, Pages, Stores) ->
  _.extend(Products, Content, Pages, Stores)