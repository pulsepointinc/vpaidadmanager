window.ppa.jsvpaid.FlashPlayer = function(linearNode, vpaidReadyCallback) {
    var self = this;

    this.classConstructor = arguments.callee;
    this.linearNode = linearNode;
    this.id = "ppaFlashJSWrapper_" + String(new Date().getTime());

    this.mediaFile = this.linearNode.mediaFile.flashVpaid;
    var player = window.ppa.jsvpaid.MainPlayer.getInstance();

    var swfPath = "__FLASH_JS_WRAPPER_PATH__";

    window.ppa.flashjswrapper = window.ppa.flashjswrapper || {};
    window.ppa.flashjswrapper.callback = window.ppa.flashjswrapper.callback || {};
    window.ppa.flashjswrapper.callback[self.id] = function(event, data){
      switch (event) {
        case "wrapperLoaded":
          vpaidReadyCallback(self);
          break;
        case "wrapperReady":
          document.getElementById(self.id).initAd(
              player.width,
              player.height,
              "normal",
              0, self.linearNode.adParameters,
              null);
          break;
        default:
          self.callEvent(event);
          break;
      }
    }

    var callbackName = "window.ppa.flashjswrapper.callback." + self.id;
    var htmlCode = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="100%" height="100%" id="' + self.id + '_alt" align="left">' +
        '<param name="movie" value="' + swfPath + '" />' +
        '<param name="flashVars" value="callback=' + callbackName + '" />' +
        '<param name="quality" value="high" />' +
        '<param name="bgcolor" value="#000000" />' +
        '<param name="play" value="true" />' +
        '<param name="loop" value="false" />' +
        '<param name="wmode" value="opaque" />' +
        '<param name="scale" value="noscale" />' +
        '<param name="salign" value="lt" />' +
        '<param name="allowScriptAccess" value="always" />' +
        '<param name="allowFullscreen" value="true" />' +
        '<!--[if !IE]>-->' +
        '<object type="application/x-shockwave-flash" data="' + swfPath + '" width="100%" height="100%" id="' + self.id + '">' +
        '<param name="movie" value="' + swfPath + '" />' +
        '<param name="flashVars" value="callback=' + callbackName + '" />' +
        '<param name="quality" value="high" />' +
        '<param name="bgcolor" value="#000000" />' +
        '<param name="play" value="true" />' +
        '<param name="loop" value="false" />' +
        '<param name="wmode" value="opaque" />' +
        '<param name="scale" value="noscale" />' +
        '<param name="salign" value="lt" />' +
        '<param name="allowScriptAccess" value="always" />' +
        '<param name="allowFullscreen" value="true" />' +
        '<!--<![endif]-->' +
        '<a href="http://www.adobe.com/go/getflash">' +
        '<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />' +
        '</a>' +
        '<!--[if !IE]>-->' +
        '</object>' +
        '<!--<![endif]-->' +
        '</object>';

    player.playerDiv.innerHTML = htmlCode;

    this.slot = null;
    this.eventsCallbacks = {};

    this.quartileEvents = [{
        event: 'AdVideoStart',
        value: 0
    }, {
        event: 'AdVideoFirstQuartile',
        value: 25
    }, {
        event: 'AdVideoMidpoint',
        value: 50
    }, {
        event: 'AdVideoThirdQuartile',
        value: 75
    }, {
        event: 'AdVideoComplete',
        value: 100
    }];

    this.lastQuartileIndex = 0;

    this.parameters = {};

    this.initAd = function(
        width,
        height,
        viewMode,
        desiredBitrate,
        creativeData,
        environmentVars) {
        self.slot = environmentVars.slot;

        self.parameters = creativeData.AdParameters;

        document.getElementById(self.id).loadWrapper(self.mediaFile);
    };

    this.callEvent = function(eventType) {
        if (eventType in self.eventsCallbacks) {
            if (typeof self.eventsCallbacks[eventType] == 'function') {
                self.eventsCallbacks[eventType]();
            }
        }
    };

    this.stopAd = function() {
        document.getElementById(self.id).stopAd();
        setTimeout(callback, 75, ['AdStopped']);
    };

    this.startAd = function() {
        document.getElementById(self.id).startAd();
    };

    this.handshakeVersion = function(version) {
        document.getElementById(self.id).handshakeVersion(version);
    };

    this.setAdVolume = function(value) {
        try {
            document.getElementById(self.id).setAdVolume(value);
        } catch (e) {}
    };

    this.getAdVolume = function() {
        return document.getElementById(self.id).getAdVolume();
    };

    this.resizeAd = function(width, height, viewMode) {
        document.getElementById(self.id).resizeAd(width, height, viewMode);
    };

    this.pauseAd = function() {
        return document.getElementById(self.id).pauseAd();
    };

    this.resumeAd = function() {
        return document.getElementById(self.id).resumeAd();
    };

    this.expandAd = function() {};

    this.getAdExpanded = function() {
        return false;
    };

    this.getAdSkippableState = function() {
        return false;
    };

    this.collapseAd = function() {};

    this.skipAd = function() {};

    this.subscribe = function(
        aCallback,
        eventName,
        aContext) {
        var callBack = aCallback.bind(aContext);
        self.eventsCallbacks[eventName] = callBack;
    };

    this.unsubscribe = function(eventName) {
        self.eventsCallbacks[eventName] = null;
    };

    this.getAdWidth = function() {
        return 1;
    };

    this.getAdHeight = function() {
        return 1;
    };

    this.getAdRemainingTime = function() {
        return document.getElementById(self.id).getAdRemainingTime();
    };

    this.getAdDuration = function() {
        return 1;
    };

    this.getAdCompanions = function() {
        return "";
    };

    this.getAdIcons = function() {
        return "";
    };

    this.getAdLinear = function() {
        return true;
    };

    this.getVPAIDAd = function() {
        return self;
    };


};
