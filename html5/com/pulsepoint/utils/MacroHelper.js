window.ppa.jsvpaid.MacroHelper = function() {
    this.classConstructor = arguments.callee;
    this.classConstructor.errorCode = 901;

    this.classConstructor.replaceMacro = function(str) {
        var temp = this.trim(str);
        var timestamp = String(new Date().getTime());

        temp = temp.split("[ERRORCODE]").join(this.errorCode);
        temp = temp.split("[CACHEBUSTING]").join(timestamp);

        return temp;
    };

    this.classConstructor.trim = function(str) {
        if (!str) {
            return "";
        }
        return str.replace(/^s+|\s+/g, "");
    }
};

new window.ppa.jsvpaid.MacroHelper();
