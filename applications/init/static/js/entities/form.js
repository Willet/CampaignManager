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

define(["entities/base"], function (Base) {
    var Entities, validators;
    Entities = Entities || {};
    validators = {
        emailVal: function (model) {
            'Rules:\nEmail has only one @\nPart before @ is of length 2-50\nPart before @ has only Alphanumerics, hypens, and periods\nPart before @ has no consecutive periods or periods at beginning or end\nPart after @ has exactly one period\nPart after @ but before . is of length 2-90\nPart after @ but before . is only Alphanumbers and hyphens\nPart after @ but before . has no hypens at start or end\nPart after . is only 2 - 4 characters of alpha chars';

            var domain, local, m, regex, rest, tld;
            regex = /^([^@]*)@([^@]*)$/;
            if (!(m = model.get('value').match(regex))) {
                return "Err: Email must have exactly one @";
            }
            local = m[1];
            rest = m[2];
            if (local.length < 2 || local.length > 50) {
                return "Err: Part before @ of email must be between 2 and 50 characters long";
            }
            regex = /^[a-zA-Z0-9\.-]*$/;
            if (!local.match(regex)) {
                return "Err: Part before @ of email can only include letters, digits, periods, and hypens (-)";
            }
            regex = /^((\..*)|(.*\.)|(.*\.\..*))$/;
            if (local.match(regex)) {
                return "Err: Part before @ of email can not start or end with a period or contain two consecutive periods";
            }
            regex = /^([^\.]*)\.([^\.]*)$/;
            if (!(m = rest.match(regex))) {
                return "Err: Part after @ must have exactly one period";
            }
            domain = m[1];
            tld = m[2];
            if (domain.length < 2 || domain.length > 90) {
                return "Err: Part from @ to '.' must be between 2 and 90 characters long";
            }
            regex = /^[a-zA-Z0-9-]*$/;
            if (!domain.match(regex)) {
                return "Err: Part from @ to '.' can only include letters, digits, or hypens (-)";
            }
            if (domain[0] === "-" || domain[-1] === "-") {
                return "Err: Part from @ to '.' can not start or end with a hypen (-)";
            }
            regex = /^[a-zA-Z]{2,4}$/;
            if (!tld.match(regex)) {
                return "Err: Part after '.' must consist of 2-4 letters";
            }
            return true;
        },
        urlVal: function (model) {
            'For simplicity I am going to ignore anything after a \'?\' symbol or \'#\'\n  The preceeding part is judged valid if it:\n- Starts with \'http\' or \'https\'\n- Followed by \'://\'\n- after which there are one or two text chunks (seperated by a period)\n  - text chunks are made up of alphanumerics only\n- followed by periond and a short text-only chunk thats 2-4 characters (ex: com, info)\n  - Url may end here, optionally with a single /\n- If not, there is a sequence of \'/TEXT\' chunks\n  - TEXT consists of alphanumerics, underscores, or hypens\n- Url can optionally end with a file name extension or a single /\n  name is made up of 2 - 10 alphanumerics';

            var basicUrl, m, optFirstChunk, regex, rest, secondChunk, thirdChunk;
            regex = /^([^#\?]*)((#|\?).*)?$/;
            m = model.get('value').match(regex);
            basicUrl = m[1];
            regex = /^((http)|(https)):\/\/(.*)/;
            if (!(m = basicUrl.match(regex))) {
                return "Err: Url must start with 'http' or 'https' followed by '://'";
            }
            rest = m[4];
            regex = /^(([^\.\/]+)\.)?([^\.\/]+)\.([^\.\/]+)((\/|$).*)/;
            if (!(m = rest.match(regex))) {
                return "Err: '://' must be followed by 2-3 chunks of text seperated by periods and, if the url does not end, ending with a '/'";
            }
            optFirstChunk = m[2];
            secondChunk = m[3];
            thirdChunk = m[4];
            rest = m[5];
            regex = /^[a-zA-Z0-9_-]+$/;
            if (((optFirstChunk != null) && !optFirstChunk.match(regex)) || !secondChunk.match(regex)) {
                return "Err: Domain name (after :// and before extension such as '.com') may only consist of letters, digits, underscores, or hypens (-) and be optionally partitioned by one period";
            }
            regex = /^[a-zA-Z]{2,4}$/;
            if (!thirdChunk.match(regex)) {
                return "Err: Domain extension (ex: .com) must consist of 2-4 letters";
            }
            if (!(rest != null) || rest === "" || rest === "/") {
                return true;
            }
            regex = /^(\/[\w-]+)+((\..*)|\/)?$/;
            if (!(m = rest.match(regex))) {
                return "Err: Domain directories must only consits of letters, digits, undersores, and hypens";
            }
            rest = m[2];
            if (!(rest != null) || rest === "" || rest === "/") {
                return true;
            }
            regex = /^\.[a-zA-Z0-9]{2,10}$/;
            if (!rest.match(regex)) {
                return "Err: Filename extensions must consist of 2-10 letters, or digits";
            }
            return true;
        }
    };
    Entities.FormElem = (function (_super) {

        __extends(FormElem, _super);

        function FormElem() {
            return FormElem.__super__.constructor.apply(this, arguments);
        }

        FormElem.prototype.defaults = {
            value: null
        };

        FormElem.prototype.validate = function () {
            var valFun, validatorName;
            validatorName = this.get("validator");
            if (!(validatorName != null)) {
                return "Err: No validator specified";
            }
            console.log(validatorName);
            valFun = validators[validatorName];
            if (!(valFun != null)) {
                return "Err: Invalid validator name: " + validatorName;
            }
            return valFun(this);
        };

        return FormElem;

    })(Base.Model);
    Entities.FormElemCollection = (function (_super) {

        __extends(FormElemCollection, _super);

        function FormElemCollection() {
            return FormElemCollection.__super__.constructor.apply(this,
                arguments);
        }

        FormElemCollection.prototype.model = Entities.FormElem;

        FormElemCollection.prototype.validate = function () {
            var errors, m, r, _i, _len, _ref;
            errors = [];
            _ref = this.models;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                m = _ref[_i];
                r = m.validate();
                if (r !== true) {
                    errors.push([m, r]);
                }
            }
            if (errors.length === 0) {
                return true;
            } else {
                return errors;
            }
        };

        FormElemCollection.prototype.getConfigJSON = function () {
            var jsonObj, m, _i, _len, _ref;
            jsonObj = {};
            _ref = this.models;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                m = _ref[_i];
                jsonObj[m.get('var')] = m.get('value');
            }
            return jsonObj;
        };

        return FormElemCollection;

    })(Base.Collection);
    return Entities;
});
