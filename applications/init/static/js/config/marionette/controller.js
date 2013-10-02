require(["marionette"], function (Marionette) {
    return _.extend(Backbone.Marionette.Controller.prototype, {
        setRegion: function (region) {
            return this.region = region;
        }
    });
});
