require(["backbone"], function (Backbone) {
    return _.extend(Backbone.Collection.prototype, {
        viewJSON: function () {
            return this.collect(function (m) {
                return m.viewJSON();
            });
        }
    });
});
