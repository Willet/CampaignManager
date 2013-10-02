define(["app"], function (App) {
    var Base;
    Base = (function () {

        Base.prototype.actions = [];

        Base.prototype.apiRoot = App.API_ROOT;

        function Base(options) {
        }

        Base.prototype._initializeActions = function () {
            var _this = this;
            return _.each(this.actions, function (action) {
                if (!_this[action]) {
                    return _this[action] = _.partial(_this._action, action);
                }
            });
        };

        Base.prototype._action = function (action, params) {
            if (params == null) {
                params = {};
            }
            return $.getJSON(this.url() + "/" + action, params);
        };

        return Base;

    })();
    return Base;
});
