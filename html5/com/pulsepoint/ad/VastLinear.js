window.ppa.jsvpaid.VastLinear = function(adNode) {
    var self = this;

    this.classConstructor = arguments.callee;

    var DomHelper = window.ppa.jsvpaid.DomHelper;
    var MacroHelper = window.ppa.jsvpaid.MacroHelper;

    this.id = "";
    this.title = "";
    this.adSystem = "";
    this.clickThroughUrl = "";
    this.mediaFile = {};
    this.adParameters = "";

    this.pixels = {
        "impression": new Array(),
        "creativeView": new Array(),
        "start": new Array(),
        "firstQuartile": new Array(),
        "midpoint": new Array(),
        "thirdQuartile": new Array(),
        "complete": new Array(),
        "click": new Array(),
        "mute": new Array(),
        "unmute": new Array(),
        "pause": new Array(),
        "resume": new Array(),
        "expand": new Array(),
        "collapse": new Array(),
        "acceptInvitation": new Array(),
        "close": new Array(),
        "error": new Array()
    };

    function setInLine(inline) {
        self.id = inline.getAttribute("id");
        self.title = DomHelper.getXMLNodeValue(inline, 'AdTitle');
        self.adSystem = DomHelper.getXMLNodeValue(inline, 'AdSystem');

        var imps = inline.getElementsByTagName('Impression');
        for (var i = 0; i < imps.length; i++) {
            var text = DomHelper.getXMLNodeValue(imps[i]);
            self.pixels.impression.push(text);
        }

        var imps = inline.getElementsByTagName('Error');
        for (var i = 0; i < imps.length; i++) {
            var text = DomHelper.getXMLNodeValue(imps[i]);
            self.pixels.error.push(text);
        }

        var creatives = inline.getElementsByTagName('Creative');
        if (creatives.length > 0) {
            var creative = creatives[0];

            var trackings = creative.getElementsByTagName('Tracking');

            for (var i = 0; i < trackings.length; i++) {
                var text = DomHelper.getXMLNodeValue(trackings[i]);
                var event = trackings[i].getAttribute("event");
                if (event && self.pixels[event]) {
                    self.pixels[event].push(text);
                }
            }

            var clickThrough = creative.getElementsByTagName('ClickThrough');
            for (var j = 0; j < clickThrough.length; j++) {
                var clickThroughUrl = DomHelper.getXMLNodeValue(clickThrough[j]);
                self.clickThroughUrl = MacroHelper.replaceMacro(clickThroughUrl);
            }

            var clickTracking = creative.getElementsByTagName('ClickTracking');
            for (var i = 0; i < clickTracking.length; i++) {
                var clickTrackingUrl = DomHelper.getXMLNodeValue(clickTracking[i]);
                clickTrackingUrl = MacroHelper.replaceMacro(clickTrackingUrl);
                self.pixels.click.push(clickTrackingUrl);
            }

            var mediaFiles = creative.getElementsByTagName('MediaFile');
            var tempVideo = document.createElement('video');

            self.mediaFile.videoFiles = new Array;

            for (var i = 0; i < mediaFiles.length; i++) {
                var mediaFile = mediaFiles[i];
                var file = DomHelper.getXMLNodeValue(mediaFile);
                var mediaType = mediaFile.getAttribute("type");

                if (!mediaType || !file || file === ""){
        					continue;
        				}

                if (tempVideo.canPlayType(mediaType) != '') {
                  self.mediaFile.videoFiles.push(file);
                }

                if (mediaType == "application/javascript") {
                    self.mediaFile.jsVpaid = file;
                }

                if (mediaType == "application/x-shockwave-flash") {
                    self.mediaFile.flashVpaid = file;
                }
            }
        }

        if (self.mediaFile.videoFiles.length >= 1) {
            self.adParameters = {
                videos: self.mediaFile.videoFiles,
                linearNode: self
            };
        } else {
            self.adParameters = DomHelper.getXMLNodeValue(inline, "AdParameters");
        }
    };

    function addPixel(event, url) {
        self.pixels[event].push(url);
    };

    this.mergePixels = function(pixels) {
        for (var p in pixels) {
            for (var pp in pixels[p]) {
                addPixel(p, pixels[p][pp]);
            }
        }
    };

    setInLine(adNode);
};
