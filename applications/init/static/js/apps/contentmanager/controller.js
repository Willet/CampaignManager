var __hasProp = {}.hasOwnProperty,
    __extends = function (child, parent) {
        for (var key in parent) {
            if (__hasProp.call(parent, key)) {
                child[key] = parent[key];
            }
        }
        function ctor() {
            this.constructor = child;
        }

        ctor.prototype = parent.prototype;
        child.prototype = new ctor();
        child.__super__ = parent.prototype;
        return child;
    };

define(['./app', 'backboneprojections', 'marionette', 'jquery', 'underscore', './views', 'views/main', 'components/views/content_list', 'entities', './views/content_list', './views/edit_area', './views/index_layout', './views/list_controls', './views/quick_view', './views/tagged_inputs'],
    function (ContentManager, BackboneProjections, Marionette, $, _, Views,
              MainViews, ContentList, Entities) {
        ContentManager.Controller = (function (_super) {

            __extends(Controller, _super);

            function Controller() {
                return Controller.__super__.constructor.apply(this, arguments);
            }

            Controller.prototype.contentIndex = function (store_id) {
                var contents, store,
                    _this = this;
                store = App.request("store:entity", store_id);
                App.execute("when:fetched", store, function () {
                    return App.nav.show(new MainViews.Nav({
                        model: new Entities.Model({
                            store: store,
                            page: 'content'
                        })
                    }));
                });
                contents = App.request("content:entities:paged", store_id);
                contents.getNextPage();
                return App.execute("when:fetched", [contents], function () {
                    App.show(ContentList.createView(contents));
                    return App.setTitle("Content");
                });
            };

            return Controller;

        })(Marionette.Controller);
        return ContentManager;
    });
