window.ppa.jsvpaid.Logger = function() {
    this.classConstructor = arguments.callee;

    this.classConstructor.log = function(msg) {
        console.log("vpaid:" + msg);
    };
};

new window.ppa.jsvpaid.Logger();
