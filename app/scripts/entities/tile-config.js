define([
    "app", "entities/base", "entities/products", "underscore"
], function (App, Base, Entities, _) {
    "use strict";
    Entities = Entities || {};

    Entities.TileConfigCollection = Base.Collection.extend({
        parse: function(response) {
            return response.results;
        }
    });

    return Entities;
});