define(["app", "dao/base", "entities"], function (App, Base, Entities) {
    var API;
    API = {
        getStore: function (store_id, params) {
            var store;
            if (params == null) {
                params = {};
            }
            store = new Entities.Store();
            store.url = "" + App.API_ROOT + "/stores/" + store_id;
            store.fetch({
                reset: true,
                data: params
            });
            return store;
        },
        getStores: function (params) {
            var stores;
            if (params == null) {
                params = {};
            }
            stores = new Entities.StoreCollection();
            stores.url = "" + App.API_ROOT + "/stores";
            stores.fetch({
                reset: true,
                data: params
            });
            return stores;
        }
    };
    if (App.mode === "local") {
        API = {
            getStore: function (store_id, params) {
                if (params == null) {
                    params = {};
                }
                return new Entities.Store({
                    id: store_id,
                    name: "Second Funnel"
                });
            },
            getStores: function (params) {
                if (params == null) {
                    params = {};
                }
                return new Entities.StoreCollection(this.getStore(126,
                    params));
            }
        };
    }
    App.reqres.setHandler("store:entities", function (params) {
        return API.getStores(params);
    });
    return App.reqres.setHandler("store:entity", function (store_id, params) {
        return API.getStore(store_id, params);
    });
});
