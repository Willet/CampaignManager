require(["marionette", "handlebars", "templates", "swag"],
    function (Marionette, Handlebars, JST) {
        Swag.registerHelpers(Handlebars);
        Handlebars.partials = JST;
        return _.extend(Marionette.Renderer, {
            render: function (template, data) {
                var templateFunction;
                if (template === false) {
                    return;
                }
                templateFunction = this.getTemplate(template);
                if (!templateFunction) {
                    throw "Template '" + template + "' does not exist!";
                }
                return templateFunction(data);
            },
            getTemplate: function (template) {
                var template_name;
                template_name = _.result({
                    t: template
                }, 't');
                return template = JST[template_name];
            }
        });
    });
