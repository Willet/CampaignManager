require(['backbone', 'jquery'], function (Backbone, $) {
    $(document).on("click", "a[href^='/']", function (event) {
        var href, passThrough, url;
        href = $(event.currentTarget).attr('href');
        passThrough = href.indexOf('sign_out') >= 0;
        if (!passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
            event.preventDefault();
            url = href.replace(/^\//, '').replace('\#\!\/', '');
            Backbone.history.navigate(url, {
                trigger: true
            });
            document.body.scrollTop = 0;
            return false;
        }
    });
    return $(document).on("click", 'a[href*=#]:not([href=#])',
        function (event) {
            var target;
            if (location.pathname.replace(/^\//,
                '') === this.pathname.replace(/^\//,
                '') || location.hostname === this.hostname) {
                target = $("[name=" + (this.hash.slice(1)) + "]");
                if (target.length) {
                    $('html,body').animate({
                        scrollTop: target.offset().top
                    }, 1000);
                    return false;
                }
            }
        });
});
