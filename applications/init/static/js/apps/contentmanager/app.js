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
    },
    __bind = function (fn, me) {
        return function () {
            return fn.apply(me, arguments);
        };
    };

define(['app', 'backboneprojections', 'marionette', 'jquery', 'underscore', './views', 'entities', 'exports', './controller', './views/content_list', './views/edit_area', './views/index_layout', './views/list_controls', './views/quick_view', './views/tagged_inputs'],
    function (App, BackboneProjections, Marionette, $, _, Views, Entities,
              ContentManager) {
        var FrequencyList, TagData;
        ContentManager.Router = (function (_super) {

            __extends(Router, _super);

            function Router() {
                return Router.__super__.constructor.apply(this, arguments);
            }

            Router.prototype.appRoutes = {
                ":store_id/content": "contentIndex"
            };

            return Router;

        })(Marionette.AppRouter);
        TagData = (function () {

            function TagData(collection) {
                this.getTaggedPageIdsFor = __bind(this.getTaggedPageIdsFor,
                    this);

                this.getTaggedProductIdsFor = __bind(this.getTaggedProductIdsFor,
                    this);

                this.untagWithPage = __bind(this.untagWithPage, this);

                this.tagWithPage = __bind(this.tagWithPage, this);

                this.untagWithProduct = __bind(this.untagWithProduct, this);

                this.tagWithProduct = __bind(this.tagWithProduct, this);

                this.addContent = __bind(this.addContent, this);

                var _this = this;
                this.contentIds = [];
                this.taggedProducts = [];
                this.taggedPages = [];
                collection.each(function (m) {
                    return _this.addContent(m.get('id'));
                });
            }

            TagData.prototype.addContent = function (contId) {
                var idx;
                idx = this.insertIntoSortedArray(this.contentIds, contId);
                this.taggedProducts.splice(idx, 0, []);
                return this.taggedPages.splice(idx, 0, []);
            };

            TagData.prototype.tagWithProduct = function (contId, prodId) {
                return this.insertIntoSortedArray(this.getTaggedProductIdsFor(contId),
                    prodId);
            };

            TagData.prototype.untagWithProduct = function (contId, prodId) {
                var a;
                a = this.getTaggedProductIdsFor(contId);
                return a.splice(this.getIdx(a, prodId), 1);
            };

            TagData.prototype.tagWithPage = function (contId, pageId) {
                return this.insertIntoSortedArray(this.getTaggedPageIdsFor(contId),
                    pageId);
            };

            TagData.prototype.untagWithPage = function (contId, pageId) {
                var a;
                a = this.getTaggedPageIdsFor(contId);
                return a.splice(this.getIdx(a, pageId), 1);
            };

            TagData.prototype.getTaggedProductIdsFor = function (contId) {
                var r;
                r = this.taggedProducts[this.getIdx(this.contentIds, contId)];
                return r;
            };

            TagData.prototype.getTaggedPageIdsFor = function (contId) {
                var r;
                r = this.taggedPages[this.getIdx(this.contentIds, contId)];
                return r;
            };

            TagData.prototype.insertIntoSortedArray = function (a, num) {
                var idx;
                idx = 0;
                while (idx < a.length) {
                    if (a[idx] > num) {
                        break;
                    }
                    idx = idx + 1;
                }
                a.splice(idx, 0, num);
                return idx;
            };

            TagData.prototype.getIdx = function (a, num) {
                var high, low, mid;
                low = 0;
                high = a.length - 1;
                while (high > low) {
                    mid = Math.round((high - low) / 2) + low;
                    if (a[mid] === num) {
                        return mid;
                    } else {
                        if (a[mid] > num) {
                            high = mid - 1;
                        } else {
                            low = mid + 1;
                        }
                    }
                }
                if (a[low] === num) {
                    return low;
                }
                return -1;
            };

            return TagData;

        })();
        FrequencyList = (function () {

            function FrequencyList() {
                this.items = [];
                this.freq = [];
            }

            FrequencyList.prototype.addList = function (list) {
                var added, item, _i, _len;
                added = [];
                for (_i = 0, _len = list.length; _i < _len; _i++) {
                    item = list[_i];
                    if (this.addItem(item)) {
                        added.push(item);
                    }
                }
                return added;
            };

            FrequencyList.prototype.removeList = function (list) {
                var item, removed, _i, _len;
                removed = [];
                for (_i = 0, _len = list.length; _i < _len; _i++) {
                    item = list[_i];
                    if (this.removeItem(item)) {
                        removed.push(item);
                    }
                }
                return removed;
            };

            FrequencyList.prototype.addItem = function (item) {
                var idx;
                idx = this.items.indexOf(item);
                if (idx === -1) {
                    this.items.push(item);
                    this.freq.push(1);
                    return true;
                } else {
                    this.freq[idx] = this.freq[idx] + 1;
                    return false;
                }
            };

            FrequencyList.prototype.removeItem = function (item) {
                var idx;
                idx = this.items.indexOf(item);
                if (idx === -1) {
                    console.log("Error: PId to remove is not in set");
                    return false;
                }
                this.freq[idx] = this.freq[idx] - 1;
                if (this.freq[idx] === 0) {
                    this.items.splice(idx, 1);
                    this.freq.splice(idx, 1);
                    return true;
                } else {
                    return false;
                }
            };

            return FrequencyList;

        })();
        App.addInitializer(function () {
            var controller, router;
            controller = new ContentManager.Controller();
            return router = new ContentManager.Router({
                controller: controller
            });
        });
        return ContentManager;
    });
