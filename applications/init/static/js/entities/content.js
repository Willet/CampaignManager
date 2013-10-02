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

define(["app", "entities/base", "entities/products"],
    function (App, Base, Entities) {
        Entities = Entities || {};
        Entities.Content = (function (_super) {

            __extends(Content, _super);

            function Content() {
                return Content.__super__.constructor.apply(this, arguments);
            }

            Content.prototype.reject = function () {
                return this.save({
                    active: false,
                    approved: false
                });
            };

            Content.prototype.approve = function () {
                return this.save({
                    active: true,
                    approved: true
                });
            };

            Content.prototype.undecided = function () {
                return this.save({
                    active: true,
                    approved: false
                });
            };

            Content.prototype.parse = function (data) {
                var attrs;
                attrs = data;
                attrs['tagged-products'] = App.request("product:entities:set",
                    attrs['store-id'], data['tagged-products']);
                return attrs;
            };

            Content.prototype.toJSON = function () {
                var json;
                json = Content.__super__.toJSON.call(this);
                if (this.attributes['tagged-products']) {
                    json['tagged-products'] = this.get('tagged-products').collect(function (m) {
                        return m.get("id");
                    });
                }
                return json;
            };

            Content.prototype.viewJSON = function () {
                var json, video_id;
                json = this.toJSON();
                json['selected'] = this.get('selected');
                if (this.get('active')) {
                    if (this.get('approved')) {
                        json['approved'] = true;
                        json['state'] = 'approved';
                    } else {
                        json['undecided'] = true;
                        json['state'] = 'undecided';
                    }
                } else {
                    json['rejected'] = true;
                    json['state'] = 'rejected';
                }
                if (this.get('original-url') && /youtube/i.test(this.get('original-url'))) {
                    json['video'] = true;
                    video_id = this.get('original-url').match(/v=(.+)/)[1];
                    json['video-embed-url'] = this.get('original-url').replace(/watch\?v=/,
                        'embed/');
                    json['video-thumbnail'] = "http://i1.ytimg.com/vi/" + video_id + "/mqdefault.jpg";
                } else if (this.get('remote-url')) {
                    json['images'] = this.imageFormatsJSON(this.get('remote-url'));
                }
                return json;
            };

            Content.prototype.imageFormatsJSON = function (url) {
                return {
                    pico: {
                        width: 16,
                        height: 16,
                        url: url.replace('master', 'pico')
                    },
                    icon: {
                        width: 32,
                        height: 32,
                        url: url.replace('master', 'icon')
                    },
                    thumb: {
                        width: 50,
                        height: 50,
                        url: url.replace('master', 'thumb')
                    },
                    small: {
                        width: 100,
                        height: 100,
                        url: url.replace('master', 'small')
                    },
                    compact: {
                        width: 160,
                        height: 160,
                        url: url.replace('master', 'compact')
                    },
                    medium: {
                        width: 240,
                        height: 240,
                        url: url.replace('master', 'medium')
                    },
                    large: {
                        width: 480,
                        height: 480,
                        url: url.replace('master', 'large')
                    },
                    grande: {
                        width: 600,
                        height: 600,
                        url: url.replace('master', 'grande')
                    },
                    "1024x1024": {
                        width: 1024,
                        height: 1024,
                        url: url.replace('master', '1024x1024')
                    },
                    master: {
                        width: 2048,
                        height: 2048,
                        url: url
                    }
                };
            };

            return Content;

        })(Base.Model);
        Entities.ContentCollection = (function (_super) {

            __extends(ContentCollection, _super);

            function ContentCollection() {
                return ContentCollection.__super__.constructor.apply(this,
                    arguments);
            }

            ContentCollection.prototype.model = Entities.Content;

            ContentCollection.prototype.initialize = function (models, opts) {
                if (opts) {
                    return this.hasmodel = opts['model'];
                }
            };

            ContentCollection.prototype.url = function (opts) {
                var _ref,
                    _this = this;
                this.store_id = ((_ref = this.hasmodel) != null
                    ? typeof _ref.get === "function" ? _ref.get('store-id')
                                     : void 0 : void 0) || this.store_id;
                _.each(opts, function (m) {
                    return m.set("store-id", _this.store_id);
                });
                return "" + (require("app").apiRoot) + "/stores/" + this.store_id + "/content?results=21";
            };

            ContentCollection.prototype.parse = function (data) {
                return data['content'];
            };

            ContentCollection.prototype.viewJSON = function () {
                return this.collect(function (m) {
                    return m.viewJSON();
                });
            };

            return ContentCollection;

        })(Base.Collection);
        Entities.ContentPageableCollection = (function (_super) {

            __extends(ContentPageableCollection, _super);

            function ContentPageableCollection() {
                return ContentPageableCollection.__super__.constructor.apply(this,
                    arguments);
            }

            ContentPageableCollection.prototype.model = Entities.Content;

            ContentPageableCollection.prototype.initialize = function () {
                this.resetPaging();
                return this.queryParams = {};
            };

            ContentPageableCollection.prototype.selectAll = function () {
                return this.collect(function (m) {
                    return m.set('selected', true);
                });
            };

            ContentPageableCollection.prototype.unselectAll = function () {
                return this.collect(function (m) {
                    return m.set('selected', false);
                });
            };

            ContentPageableCollection.prototype.setFilter = function (options) {
                var key, val;
                for (key in options) {
                    val = options[key];
                    if (val === "") {
                        delete this.queryParams[key];
                    } else {
                        this.queryParams[key] = val;
                    }
                }
                this.reset();
                return this.getNextPage();
            };

            ContentPageableCollection.prototype.updateSortOrder = function (new_order) {
                this.queryParams['order'] = new_order;
                this.reset();
                return this.getNextPage();
            };

            ContentPageableCollection.prototype.reset = function (models,
                                                                  options) {
                ContentPageableCollection.__super__.reset.call(this, models,
                    options);
                return this.resetPaging();
            };

            ContentPageableCollection.prototype.resetPaging = function () {
                this.params = {
                    results: 25
                };
                return this.finished = false;
            };

            ContentPageableCollection.prototype.getNextPage = function (opts) {
                var collection, params, xhr,
                    _this = this;
                if (!(this.finished || this.in_progress)) {
                    this.in_progress = true;
                    collection = new Entities.ContentCollection;
                    params = _.extend(this.queryParams, this.params);
                    collection.url = this.url;
                    xhr = collection.fetch({
                        data: params,
                        reset: true
                    });
                    $.when(xhr).done(function () {
                        _this.add(collection.models, {
                            at: _this.length
                        });
                        _this.params['start-id'] = xhr.responseJSON['last-id'];
                        if (!_this.params['start-id']) {
                            _this.finished = true;
                        }
                        return _this.in_progress = false;
                    });
                }
                return xhr;
            };

            return ContentPageableCollection;

        })(Base.Collection);
        return Entities;
    });
