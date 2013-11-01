define([
    "app", "dao/base", "entities"
], function (App, Base, Entities) {
    var API = {
        getFromConfig: function(config) {
            var id, field, template;
            config = config || {};

            switch(config.template) {
                case 'product':
                    field = 'product-ids';
                    break;
                default:
                    field = 'content-ids';
            }

            id = config.id || -1;
            template = config.template || 'image';

            return {
                'id': id,
                'field': field,
                'template': template
            }
        },
        addTileConfig: function(page_id, config) {
            var tileConfigCollection, obj = {};

            config = this.getFromConfig(config);

            obj['template'] = config.template;
            obj[config.field] = [config.id];

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";
            tileConfigCollection.create(obj);
            //tileConfig.save();
        },

        deleteTileConfig: function(page_id, config) {
            var tileConfigCollection, obj = {};

            config = this.getFromConfig(config);

            obj[config.field] = config.id;

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";

            tileConfigCollection.fetch({
                data: obj
            }).done(function() {
                //http://stackoverflow.com/questions/10858935/cleanest-way-to-destroy-every-model-in-a-collection-in-backbone
                var i;
                for (i = tileConfigCollection.length -1; i >= 0; i--) {
                    tileConfigCollection.at(i).destroy();
                }
            });
        },

        // TODO: do we need config here?
        getTileConfig: function (page_id, config) {
            var tileConfigCollection, obj = {}, tileConfig;

            config = this.getFromConfig(config);

            obj[config.field] = config.id;

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";

            tileConfigCollection.fetch({
                async: false
            }).done(function(results) {
                tileConfig = tileConfigCollection;
            });
            return tileConfig;
        },

        // TODO: getTileConfigIDs lets the server do the filtering?
        //       Should we keep it or get rid of it and instead use _.filter
        //       with getTileConfig? (returns tile config for all tiles)
        getTileConfigIDs: function (page_id, config) {
            var tileConfigCollection, obj = {}, tileIDs = [];

            config = this.getFromConfig(config);
            obj[config.field] = config.id;
            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";

            tileConfigCollection.fetch({
                data: obj,
                async: false
            }).done(function(results) {
                tileIDs = tileConfigCollection.pluck('id');
            });

            // turn everything into a number so we don't compare oranges to apples
            tileIDs = _.map(tileIDs, Number)

            // get rid of all falsy values except for 0, which -- who knows -- could
            // be a valid ID
            tileIDs = _.filter(tileIDs, function (val) {
              return val == 0 || !!val
                })

            return tileIDs;
        }
    }

    App.reqres.setHandler("tileconfig:approve", function(page_id, config) {
        API.addTileConfig(page_id, config);
    });

    App.reqres.setHandler("tileconfig:reject", function(page_id, config) {
        API.deleteTileConfig(page_id, config);
    });

    App.reqres.setHandler("tileconfig:entities", function (page_id, config) {
        return API.getTileConfig();
    });

    App.reqres.setHandler("tileconfig:content:getIDs", function (page_id, config) {
        return API.getTileConfigIDs(page_id, config);
    });

//    var API = {
//        login: function (username, password) {
//            var user = new Entities.User();
//            user.url = App.API_ROOT + "/user"; //
//            user.login(username, password);
//            return user;
//        },
//        logout: function () {
//
//        }
//    };
//
//    App.reqres.setHandler("user:login", function (username, password) {
//        var user = API.login(username, password);
//        App.user = user;
//    });
});
