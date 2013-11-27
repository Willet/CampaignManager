define([
    'app', 'entities/base', 'entities/products'
], function (App, Base, Entities) {
    'use strict';
    Entities = Entities || {};

    Entities.TileConfig = Base.Model.extend({});

    Entities.TileConfigCollection = Base.Collection.extend({
        model: Entities.TileConfig
    });

    return Entities;
});
