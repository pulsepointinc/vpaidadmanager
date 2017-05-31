window.ppa.jsvpaid.MainPlayer = function() {
    var self = this;

    this.classConstructor = arguments.callee;

    this.classConstructor.DEFAULT_TIMEOUT = 15000;

    this.classConstructor.instance = self;
    this.classConstructor.getInstance = function() {
        return this.instance;
    };

    var ExternalScripts = window.ppa.jsvpaid.ExternalScripts;
    var Logger = window.ppa.jsvpaid.Logger;
    var MacroHelper = window.ppa.jsvpaid.MacroHelper;
    var Tracker = window.ppa.jsvpaid.Tracker;
    var AdLoader = window.ppa.jsvpaid.AdLoader;
    var timestamp = String(new Date().getTime());

    this.vastWrapper = null;
    this.linearNode;
    this.playerDiv;
    this.divName = "pulsepointHtml5MainStage_" + timestamp;
    this.slotName = "pulsepointHtml5Slot_" + timestamp;
    this.skipDivName = "pulsepointHtml5MainSkip_" + timestamp;
    this.environmentVars = {};
    this.VPAIDAd = null;
    this.volume = 1;

    this.width = 0;
    this.height = 0;
    this.viewMode = "Normal";
    this.adNodes = new Array();
    this.ads = new Array();
    this.currentAd;
    this.adWaitTimer;

    this.timeout = -1;

    this.startFired = false;
    this.firstQuartileFired = false;
    this.midpointFired = false;
    this.thirdQuartileFired = false;
    this.completeFired = false;

    this.eventsCallbacks = {};
    this.callbacks = {};

    this.attributes = {
        'companions': '',
        'desiredBitrate': 256,
        'duration': 30,
        'expanded': false,
        'height': 0,
        'icons': '',
        'linear': true,
        'skippableState': false,
        'viewMode': 'normal',
        'width': 0,
        'volume': 1.0
    };

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

    this.parameters = {};

    this.extScripts;

    this.resizeAd = function(width, height) {
        Logger.log("resizeAd, width=" + width + ",height=" + height);
        self.width = width;
        self.height = height;

        try {
            if (self.VPAIDAd) {
                self.VPAIDAd.resizeAd(self.width, self.height, "normal");
            }
        } catch (e) {}
    };

    this.getAdWidth = function() {
        return self.width;
    };

    this.getAdHeight = function() {
        return self.height;
    };

    this.getAdCompanions = function() {
        return '';
    };

    this.getAdIcons = function() {
        return '';
    };

    this.getAdLinear = function() {
        return true;
    };

    this.expandAd = function() {
        callEvent('AdExpanded');
    };

    this.getAdExpanded = function() {
        return false;
    };

    this.getAdSkippableState = function() {
        return false;
    };

    this.collapseAd = function() {};

    this.skipAd = function() {
        if (self.VPAIDAd) {
            try {
                self.VPAIDAd.skipAd();
            } catch (e) {}
        }
    };

    this.getAdDuration = function() {
        if (self.VPAIDAd) {
            return self.VPAIDAd.getAdDuration();
        }
        return 0;
    };

    this.getAdRemainingTime = function() {
        try {
            if (self.VPAIDAd) {
                return self.VPAIDAd.getAdRemainingTime();
            }
        } catch (e) {
            return -1;
        }
        return -1;
    };

    this.setAdVolume = function(val) {
        try {
            if (self.VPAIDAd) {
                self.VPAIDAd.setAdVolume(val);
            }
        } catch (e) {}
        self.volume = val;
    }

    this.getAdVolume = function(val) {
        try {
            if (self.VPAIDAd) {
                return self.VPAIDAd.getAdVolume();
            }
        } catch (e) {}
        return 1;
    }

    this.removePlayerReferences = function() {

    };

    this.playingAd = function() {
        return true;
    };

    this.pauseAd = function() {
        try {
            self.VPAIDAd.pauseAd();
        } catch (e) {}
    };

    this.resumeAd = function() {
        try {
            if (self.VPAIDAd) {
                self.VPAIDAd.resumeAd();
            }
        } catch (e) {}
    };

    this.handshakeVersion = function(version) {
        Logger.log("handshakeVersion, version =" + version);
        return ('2.0');
    };

    this.initAd = function(
        width,
        height,
        viewMode,
        desiredBitrate,
        creativeData,
        environmentVars) {
        Logger.log("initAd, width=" + width + ",height=" + height + ",desiredBitrate=" + desiredBitrate + ",creativeData=" + creativeData + ",environmentVars=" + environmentVars);

        self.width = width;
        self.height = height;
        self.viewMode = viewMode;
        self.desiredBitrate = desiredBitrate;
        self.parameters = JSON.parse(creativeData.AdParameters);
        if (self.parameters && !isNaN(self.parameters.timeoutMs)) {
            self.timeout = self.parameters.timeoutMs;
        } else {
            self.timeout = self.classConstructor.DEFAULT_TIMEOUT;
        }

        if (environmentVars.slot) {
            self.playerDiv = document.createElement('div');
            environmentVars.slot.appendChild(self.playerDiv);
            self.playerDiv.setAttribute("style", "width: 100%;height: 100%;top: 0px;left: 0px;position: absolute;pointer-events:auto;");

            self.environmentVars.slot = self.playerDiv;

            self.resizeAd(width, height);

            if (environmentVars.videoSlot) {
                self.environmentVars.videoSlot = environmentVars.videoSlot;
            } else {
                self.environmentVars.videoSlot = document.createElement('video');
                self.environmentVars.slot.appendChild(self.environmentVars.videoSlot);
            }
        }

        if (self.parameters.scripts && typeof self.parameters.scripts === "object"){
  				self.extScripts = new ExternalScripts(self.environmentVars.slot, self.parameters.scripts);
  			}

        if (self.parameters && self.parameters.vastEndpoints && self.parameters.vastEndpoints.length > 0) {
            for (var i = 0; i < self.parameters.vastEndpoints.length; i++) {
                var endPoint = self.parameters.vastEndpoints[i];
                self.ads.push(new AdLoader(endPoint, self.onVPAIDEvent, self.onAdLoaderExit, self.environmentVars));
            }

            if (self.ads.length === 0){
                setTimeout(function(){
                  callEvent('AdError');
                }, 300);
                return;
            }else{
                setTimeout(function(){
                  loadNextAd();
                }, 0);
            }
        } else {
            setTimeout(function(){
              callEvent('AdError');
            }, 300);
            return;
        }

        callEvent("AdLoaded");
    };

    function loadNextAd(){
        if (self.ads.length === 0){
            setTimeout(function(){
              callEvent('AdError');
            }, 300);
            return;
        }

        self.currentAd = self.ads.shift();
        self.currentAd.init();

        clearTimeout(self.adWaitTimer);
        self.adWaitTimer = null;
        self.adWaitTimer = setTimeout(function() {
            if (self.startFired){
              return;
            }

            MacroHelper.errorCode = 301;
            fireError();
            self.currentAd.destroy();
            self.currentAd.exitCallback = function(){};
            self.currentAd = null;

            setTimeout(function(){
              loadNextAd();
            }, 0);
        }, self.timeout);
      }

    this.onAdLoaderExit = function(){
        if (self.currentAd){
            fireError(loadNextAd);
            self.currentAd.destroy();
            self.currentAd.exitCallback = function(){};
            self.currentAd = null;
        }else{
          setTimeout(function(){
            loadNextAd();
          }, 0);
        }
    };

    this.onVPAIDEvent = function(event) {
        if (event === "AdImpression") {
            clearTimeout(self.adWaitTimer);
            self.adWaitTimer = null;
            if (self.currentAd) {
                self.currentAd.exitCallback = function(){};
                self.VPAIDAd = self.currentAd.VPAIDAd;
                self.linearNode = self.currentAd.linearNode;
            }else{
                setTimeout(function(){
                  callEvent('AdError');
                }, 300);
                return;
            }

            if (!self.startFired) {
                self.startFired = true;
                self.extScripts.execute();
                Tracker.fire(self.linearNode.pixels.impression);
                Tracker.fire(self.linearNode.pixels.start);
                self.resizeAd(self.width, self.height);
            }

            callEvent("AdImpression");
            return;
        }

        switch (event) {
            case "AdVideoStart":
                Tracker.fire(self.linearNode.pixels.creativeView);
                break;
            case "AdVideoFirstQuartile":
                if (!self.firstQuartileFired) {
                    Tracker.fire(self.linearNode.pixels.firstQuartile);
                    self.firstQuartileFired = true;
                }
                break;
            case "AdVideoMidpoint":
                if (!self.midpointFired) {
                    Tracker.fire(self.linearNode.pixels.midpoint);
                    self.midpointFired = true;
                }
                break;
            case "AdVideoThirdQuartile":
                if (!self.thirdQuartileFired) {
                    Tracker.fire(self.linearNode.pixels.thirdQuartile);
                    self.thirdQuartileFired = true;
                }
                break;
            case "AdVideoComplete":
                if (!self.completeFired) {
                    Tracker.fire(self.linearNode.pixels.complete);
                    self.completeFired = true;
                }
                break;
            case "AdClickThru":
                Tracker.fire(self.linearNode.pixels.click);
                break;
            case "AdPaused":
                Tracker.fire(self.linearNode.pixels.pause);
                break;
            case "AdPlaying":
                Tracker.fire(self.linearNode.pixels.resume);
                break;
            case "AdExpandedChange":
              Tracker.fire(self.linearNode.pixels.expand);
              break;
            case "AdUserMinimize":
              Tracker.fire(self.linearNode.pixels.collapse);
              break;
            case "AdUserAcceptInvitation":
              Tracker.fire(self.linearNode.pixels.acceptInvitation);
              break;
            case "AdUserClose":
              Tracker.fire(self.linearNode.pixels.close);
              break;
            case "AdStopped":
                cleanup();
                break;
            default:
                break;
        }
        callEvent(event);
    }

    this.startAd = function() {
        try {
            if (self.VPAIDAd) {
                self.VPAIDAd.startAd();
            }
        } catch (e) {}
    };

    this.stopAd = function() {
        try {
            if (self.VPAIDAd) {
                self.VPAIDAd.stopAd();
            }
        } catch (e) {}

        if (self.currentAd){
          if (!self.startFired){
            MacroHelper.errorCode = 301;
            fireError();
          }
          self.currentAd.destroy();
          self.currentAd.exitCallback = function(){};
          self.currentAd = null;
        }

        cleanup();
    };

    this.subscribe = function(
        aCallback,
        eventName,
        aContext) {
        var callBack = aCallback.bind(aContext);
        if (typeof self.eventsCallbacks[eventName] === "undefined") {
            self.eventsCallbacks[eventName] = new Array();
        }
        self.eventsCallbacks[eventName].push(callBack);
    };

    this.unsubscribe = function(eventName) {
        self.eventsCallbacks[eventName] = null;
    };

    function callEvent(eventType) {
        Logger.log("dispatching event:" + eventType);
        if (eventType in self.eventsCallbacks) {
            for (var i = 0; i < self.eventsCallbacks[eventType].length; i++) {
                setTimeout(function(eventType, i){
                  self.eventsCallbacks[eventType][i]();
                }, 0, eventType, i);
            }
        }
    };

    function fireError(callback){
      if (self.currentAd){
          var errorPixel = new Array();
          if (self.currentAd.linearNode){
            errorPixel = self.currentAd.linearNode.pixels.error;
          }else if(self.currentAd.vastWrapper){
            errorPixel = self.currentAd.vastWrapper.pixels.error;
          }
          Tracker.fire(errorPixel, callback);
      }
    };

    function cleanup(){
      if (self.extScripts){
        self.extScripts.cleanup();
      }
    };
};
