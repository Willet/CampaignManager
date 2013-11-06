define([
    'app', 'entities/base', 'entities/products'
], function (App, Base, Entities) {
    'use strict';
    Entities = Entities || {};

    Entities.TileConfigCollection = Base.Collection.extend({
        parse: function(response) {
            return response.results;
        }
    });

    return Entities;
});
