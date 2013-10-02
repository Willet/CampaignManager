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

define(["marionette", "../views", "stickit"], function (Marionette, Views) {
    Views.PageCreateLayout = (function (_super) {

        __extends(PageCreateLayout, _super);

        function PageCreateLayout() {
            return PageCreateLayout.__super__.constructor.apply(this,
                arguments);
        }

        PageCreateLayout.prototype.template = "pages_layout";

        PageCreateLayout.prototype.serializeData = function () {
            return {
                page: this.model.toJSON(),
                "store-id": this.model.get("store-id"),
                "title": this.model.get("name"),
                fields: this.getLayoutJSON()
            };
        };

        PageCreateLayout.prototype.getLayoutJSON = function () {
            var jsonFields,
                _this = this;
            jsonFields = [
                {
                    "var": "heroImageMobile",
                    label: "Hero Image (Mobile)",
                    type: "image"
                },
                {
                    "var": "legalCopy",
                    label: "Legal Copy",
                    type: "textarea"
                },
                {
                    "var": "facebookShare",
                    label: "Facebook Share Copy",
                    type: "text"
                },
                {
                    "var": "twitterShare",
                    label: "Twitter Share Copy",
                    type: "text"
                },
                {
                    "var": "emailShare",
                    label: "Email Share Copy",
                    type: "text"
                }
            ];
            _.each(jsonFields, function (field) {
                var model_value, _ref;
                if (model_value = (_ref = _this.model.get("fields")) != null
                    ? _ref[field['var']] : void 0) {
                    return field['value'] = model_value;
                }
            });
            return jsonFields;
        };

        PageCreateLayout.prototype.triggers = {
            "click .js-next": "save"
        };

        PageCreateLayout.prototype.events = {
            "click .layout-type": "selectLayoutType",
            "change .image-field": "updateImgPreview"
        };

        PageCreateLayout.prototype.getFields = function () {
            var results;
            results = {};
            _.each($("#layout-field-form textarea"), function (m) {
                if ($(m).attr("for")) {
                    return results[$(m).attr("for")] = $(m).val();
                }
            });
            _.each($("#layout-field-form input"), function (m) {
                if ($(m).attr("for")) {
                    return results[$(m).attr("for")] = $(m).val();
                }
            });
            return results;
        };

        PageCreateLayout.prototype.updateImgPreview = function (event) {
            var elem, field, fileReader, targetField, _i, _len, _ref,
                _this = this;
            elem = event.currentTarget;
            targetField = null;
            _ref = this.getLayoutJSON();
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                field = _ref[_i];
                if (field["var"] === elem.getAttribute("for")) {
                    targetField = field;
                }
            }
            fileReader = new FileReader();
            fileReader.onload = function (event) {
                targetField.loadedUrl = event.target.result;
                return _this.render();
            };
            return fileReader.readAsDataURL(elem.files[0]);
        };

        PageCreateLayout.prototype.bindings = {
            '.js-layout-hero': {
                attributes: [
                    {
                        name: 'class',
                        observe: 'layout',
                        onGet: function (val, options) {
                            if (val === "hero") {
                                return "selected";
                            } else {
                                return "";
                            }
                        }
                    }
                ]
            },
            '.js-layout-featured': {
                attributes: [
                    {
                        name: 'class',
                        observe: 'layout',
                        onGet: function (val, options) {
                            if (val === "featured") {
                                return "selected";
                            } else {
                                return "";
                            }
                        }
                    }
                ]
            },
            '.js-layout-shopthelook': {
                attributes: [
                    {
                        name: 'class',
                        observe: 'layout',
                        onGet: function (val, options) {
                            if (val === "shopthelook") {
                                return "selected";
                            } else {
                                return "";
                            }
                        }
                    }
                ]
            }
        };

        PageCreateLayout.prototype.selectLayoutType = function (event) {
            var layoutClicked, new_layout;
            layoutClicked = this.$(event.currentTarget);
            this.$('#layout-types .layout-type').removeClass('selected');
            layoutClicked.addClass('selected');
            new_layout = this.extractClassSuffix(this.$(event.currentTarget),
                'js-layout');
            this.trigger('layout:selected', new_layout);
            return this.model.set('layout', new_layout);
        };

        PageCreateLayout.prototype.initialize = function (opts) {
        };

        PageCreateLayout.prototype.onRender = function (opts) {
            this.stickit();
            return this.$(".steps .layout").addClass("active");
        };

        PageCreateLayout.prototype.onShow = function (opts) {
        };

        return PageCreateLayout;

    })(Marionette.Layout);
    return Views;
});
