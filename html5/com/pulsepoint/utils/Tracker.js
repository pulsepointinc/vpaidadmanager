window.ppa.jsvpaid.Tracker = function() {
    var MacroHelper = window.ppa.jsvpaid.MacroHelper;

    this.classConstructor = arguments.callee;

    this.classConstructor.Image = Image;

    this.classConstructor.fire = function(pixel) {
        if (pixel) {
            for (var i = 0; i < pixel.length; i++) {
                if (pixel[i] && pixel[i] != "") {
                    var img = new this.Image();
                    img.src = MacroHelper.replaceMacro(pixel[i]);
                }
            }
        }
    };
};

new window.ppa.jsvpaid.Tracker();
