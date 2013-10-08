define(["marionette"], function (Marionette) {
    "use strict";
    var Login;  // it's a local variable. how's this work?

    Login = Marionette.Layout.extend({
        template: "login"
    });
    return Login;
});
