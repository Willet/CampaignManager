define(['jquery'], function ($) {
    'use strict';
    $.ajaxSetup({
        // there are records online that indicate this works, but...
        beforeSend: function (request) {
            request.setRequestHeader('ApiKey', 'secretword');
            request.withCredentials = true;
            request.xhrFields = {
                withCredentials: true
            };
            return request;
        },
        // ... it took these to work, at least for chrome.
        withCredentials: true,
        xhrFields: {
            withCredentials: true
        }
    });
});