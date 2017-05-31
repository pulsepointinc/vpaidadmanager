window.ppa.jsvpaid.Tracker = function() {
    var MacroHelper = window.ppa.jsvpaid.MacroHelper;

    this.classConstructor = arguments.callee;

    this.classConstructor.Image = Image;

    this.classConstructor.fire = function(pixel, callback) {
        if (pixel) {
            for (var i = 0; i < pixel.length; i++) {
                if (pixel[i] && pixel[i] != "") {
                    if (typeof navigator.sendBeacon === "function"){
                      navigator.sendBeacon(MacroHelper.replaceMacro(pixel[i]));

                      if (i === (pixel.length -1) && typeof callback === "function"){
                          callback();
                      }
                    }else{
                      var img = new this.Image();
                      img.src = MacroHelper.replaceMacro(pixel[i]);
                      if (i === (pixel.length -1) && typeof callback === "function"){
                          img.onload=function(){
                            callback();
                          }
                      }
                    }
                }
            }
        }
    };
};

new window.ppa.jsvpaid.Tracker();
