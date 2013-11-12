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

        getTileConfig: function (page_id, config) {
            var tileConfigCollection, obj = {}, tileConfig;

            config = this.getFromConfig(config);

            obj[config.field] = config.id;

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";

            tileConfigCollection.fetch({
                async: false
            });
            return tileConfigCollection;
        },

        /**
         * Returns a list of tile IDs for the page passed to the function.
         * If parameter config contains a key id, then we will only fetch the
         * tiles associated with that ID. Ensure it's a content ID, and that
         * it's numerical.
         *
         * if config does not contain the key id, we will return all the tile IDs
         * in the current page
         *
         * @param page_id {Integer} Page ID
         * @param config {Object} (optional) If it contains id:val where val is
         *                        number above -1, then we will only fetch the
         *                        id associated with that content ID.
         * @returns {Array}
         */
        getTileConfigIDs: function (page_id, config) {
            var tileConfigCollection, obj = {}, tileIDs = [];

            config = this.getFromConfig(config);
            obj[config.field] = config.id;

            // If no specific content ID was passed, get all tile IDs
            if (obj[config.field] === -1) {
                delete obj[config.field]
            }
            console.log(obj);
            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + "/page/" + page_id + "/tile-config";

            tileConfigCollection.fetch({
                data: obj,
                // I could not come up with a better solution (in 3 hours)
                async: false
            });
            tileIDs = tileConfigCollection.pluck('id');

            // turn everything into a number so we don't compare oranges to apples
            tileIDs = _.map(tileIDs, Number)

            // get rid of all falsy values
            tileIDs = _.filter(tileIDs, function (val) {
                return val
            });

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
        return API.getTileConfig(page_id, config);
    });

    App.reqres.setHandler("tileconfig:IDs", function (page_id, config) {
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
