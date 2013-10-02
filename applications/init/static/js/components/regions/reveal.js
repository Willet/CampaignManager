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

define(["marionette", "foundation/reveal"], function (Marionette, Reveal) {
    var RevealDialog;
    RevealDialog = (function (_super) {

        __extends(RevealDialog, _super);

        function RevealDialog() {
            return RevealDialog.__super__.constructor.apply(this, arguments);
        }

        RevealDialog.prototype.onShow = function () {
            var _this = this;
            this.$el.addClass("reveal-modal");
            this.animationSpeed = 250;
            this.$el.foundation('reveal', 'open', {
                animationSpeed: this.animationSpeed,
                closed: function () {
                    return _this.close();
                }
            });
            $('.reveal-modal-bg').on('click', function () {
                return _this.$el.foundation('reveal', 'close');
            });
            return this.$el.find('.reveal-close').on('click', function () {
                return _this.$el.foundation('reveal', 'close');
            });
        };

        RevealDialog.prototype.onClose = function (view) {
            return this.$el.removeClass("reveal-modal");
        };

        return RevealDialog;

    })(Marionette.Region);
    return {
        RevealDialog: RevealDialog
    };
});
