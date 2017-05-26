window.ppa.jsvpaid.AdLoader = function(endPoint, vpaidEventCallback, adLoaderExitCallback, envVars) {
  var self = this;

  var DomHelper = window.ppa.jsvpaid.DomHelper;
  var MacroHelper = window.ppa.jsvpaid.MacroHelper;
  var VastWrapper = window.ppa.jsvpaid.VastWrapper;
  var Tracker = window.ppa.jsvpaid.Tracker;
  var Logger = window.ppa.jsvpaid.Logger;
  var FlashPlayer = window.ppa.jsvpaid.FlashPlayer;
  var VideoPlayer = window.ppa.jsvpaid.VideoPlayer;
  var MainPlayer = window.ppa.jsvpaid.MainPlayer;

  this.classConstructor = arguments.callee;

  var player = MainPlayer.getInstance();

  this.endPoint = endPoint;
  this.callback = vpaidEventCallback;
  this.exitCallback = adLoaderExitCallback;
  this.environmentVars = envVars;
  this.vpaidFrame;

  this.vastWrapper = null;
  this.linearNode;
  this.creativeData;

  this.destroyed = false;

  var impressionFired = false;
  var cachedEvents = new Array;

  var retriedWithoutCred = false;

  this.init = function() {
    if (self.endPoint.indexOf("data:application/xml") === 0) {
      var xmlString = decodeURIComponent(self.endPoint.substring(21));
      var parser = new DOMParser();
      self.xmlDoc = parser.parseFromString(xmlString, "text/xml");
      parseAdXml(self.xmlDoc);
    } else {
      var filteredUrl = MacroHelper.replaceMacro(self.endPoint);
      loadDoc(filteredUrl);
    }
  };

  function loadDoc(url) {
    if (self.destroyed) {
      MacroHelper.errorCode = 901;
      self.exitCallback();
      return;
    }

    var xhttp;
    if (window.XMLHttpRequest) {
      // code for modern browsers
      xhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }

    xhttp.onreadystatechange = function() {
      if (self.destroyed) {
        MacroHelper.errorCode = 901;
        self.exitCallback();
        return;
      }

      if (xhttp.readyState == 4) {
        if (xhttp.status == 200) {
          var parser = new DOMParser();
          self.xmlDoc = parser.parseFromString(xhttp.responseText, "text/xml");
          parseAdXml(self.xmlDoc);
        } else if (xhttp.status == 0 && !retriedWithoutCred) {
          retriedWithoutCred = true;
          xhttp.abort();
          xhttp.open("GET", url, true);
          xhttp.withCredentials = false;
          xhttp.send();
        } else {
          MacroHelper.errorCode = 100;
          self.exitCallback();
        }
      }
    };

    try {
      Logger.log("loading ad from " + url);
      xhttp.open("GET", url, true);
      xhttp.withCredentials = true;
      retriedWithoutCred = false;
      xhttp.send();
    } catch (e) {
      MacroHelper.errorCode = 100;
      self.exitCallback();
    }
  };

  function parseAdXml(adXml) {
    if (adXml) {
      var ads = adXml.getElementsByTagName("Ad");
      var adNodes = new Array();
      for (var i = 0; i < ads.length; i++) {
        adNodes.push(ads[i]);
      }

      if (adNodes.length > 0) {
        self.vastWrapper = new VastWrapper();
        self.vastWrapper.subscribe(onVastObjectDone, VastWrapper.DONE);
        self.vastWrapper.init(adNodes[0]);
      } else {
        var errorNodes = adXml.getElementsByTagName("Error");
        if (errorNodes) {
          MacroHelper.errorCode = 100;
          var errorPixels = new Array();
          for (var j = 0; i < errorNodes.length; j++) {
            errorPixels.push(DomHelper.getXMLNodeValue(errorNodes[j]));
          }

          Tracker.fire(errorPixels);
        }

        onVastObjectDone();
      }
    }
  };

  function onVastObjectDone() {
    if (self.vastWrapper && self.vastWrapper.linearNodes && self.vastWrapper.linearNodes[0]) {
      self.linearNode = self.vastWrapper.linearNodes[0];

      if (self.adNode && self.adNode.pixels) {
        self.linearNode.mergePixels(self.adNode.pixels);
      }

      if (self.linearNode.adParameters && self.linearNode.adParameters.videos && self.linearNode.adParameters.videos.length > 0) {
        var videoPlayer = new VideoPlayer(self.adNode);
        self.onVPAIDReady(videoPlayer);
      } else if (self.linearNode.mediaFile.jsVpaid) {
        loadVPAID();
      } else if (self.linearNode.mediaFile.flashVpaid) {
        self.flashJSWrapper = new FlashPlayer(self.linearNode, self.onVPAIDReady);
      } else {
        MacroHelper.errorCode = 100;
        self.exitCallback();
      }
    } else {
      MacroHelper.errorCode = 100;
      self.exitCallback();
    }
  }

  function loadVPAID() {
    self.vpaidFrame = document.createElement('iframe');
    self.vpaidFrame.style.display = 'none';

    self.vpaidFrame.onload = function() {
      var url = self.linearNode.mediaFile.jsVpaid;

      var vpaidLoader = self.vpaidFrame.contentWindow.document.createElement('script');
      vpaidLoader.src = url;

      vpaidLoader.onload = function() {
        self.onVPAIDReady({
          "getVPAIDAd": self.vpaidFrame.contentWindow.getVPAIDAd
        });
      };

      self.vpaidFrame.contentWindow.document.body.appendChild(vpaidLoader);
    };

    self.vpaidFrame.onerror = function() {
      MacroHelper.errorCode = 901;
      self.exitCallback();
    };

    document.body.appendChild(self.vpaidFrame);
  };

  this.onVPAIDEvent = function(event) {
    switch (event) {
      case "AdError":
        MacroHelper.errorCode = 901;
        self.exitCallback();
        return;
      case "AdImpression":
        impressionFired = true;
        self.callback(event);
        for (var i = 0; i < cachedEvents.length; i++) {
          if (typeof self.callback === "function") {
            self.callback(cachedEvents[i]);
          }
        }
        return;
      default:
        break;
    }

    if (!impressionFired) {
      cachedEvents.push(event);
    } else {
      if (typeof self.callback === "function") {
        self.callback(event);
      }
    }
  };

  this.onVPAIDReady = function(vpaid) {
    var fn;

    if (vpaid) {
      fn = vpaid.getVPAIDAd;
    }

    if (fn && typeof fn === 'function') {
      self.VPAIDAd = fn();
    }

    self.eventCallbacks = {
      AdStarted: function() {
        self.onVPAIDEvent('AdStarted');
      },
      AdStopped: function() {
        self.onVPAIDEvent('AdStopped');
      },
      AdSkipped: function() {
        self.onVPAIDEvent('AdSkipped');
      },
      AdLoaded: function() {
        try {
          if (self.VPAIDAd) {
            self.VPAIDAd.startAd();
          }
        } catch (e) {}
      },
      AdLinearChange: function() {
        self.onVPAIDEvent('AdLinearChange');
      },
      AdSizeChange: function() {
        self.onVPAIDEvent('AdSizeChange');
      },
      AdExpandedChange: function() {
        self.onVPAIDEvent('AdExpandedChange');
      },
      AdSkippableStateChange: function() {
        self.onVPAIDEvent('AdSkippableStateChange');
      },
      AdDurationChange: function() {
        self.onVPAIDEvent('AdDurationChange');
      },
      AdRemainingTimeChange: function() {
        self.onVPAIDEvent('AdRemainingTimeChange');
      },
      AdVolumeChange: function() {
        self.onVPAIDEvent('AdVolumeChange');
      },
      AdImpression: function() {
        self.onVPAIDEvent('AdImpression');
      },
      AdClickThru: function() {
        self.onVPAIDEvent('AdClickThru');
      },
      AdInteraction: function() {
        self.onVPAIDEvent('AdInteraction');
      },
      AdVideoStart: function() {
        self.onVPAIDEvent('AdVideoStart');
      },
      AdVideoFirstQuartile: function() {
        self.onVPAIDEvent('AdVideoFirstQuartile');
      },
      AdVideoMidpoint: function() {
        self.onVPAIDEvent('AdVideoMidpoint');
      },
      AdVideoThirdQuartile: function() {
        self.onVPAIDEvent('AdVideoThirdQuartile');
      },
      AdVideoComplete: function() {
        self.onVPAIDEvent('AdVideoComplete');
      },
      AdUserAcceptInvitation: function() {
        self.onVPAIDEvent('AdUserAcceptInvitation');
      },
      AdUserMinimize: function() {
        self.onVPAIDEvent('AdUserMinimize');
      },
      AdUserClose: function() {
        self.onVPAIDEvent('AdUserClose');
      },
      AdPaused: function() {
        self.onVPAIDEvent('AdPaused');
      },
      AdPlaying: function() {
        self.onVPAIDEvent('AdPlaying');
      },
      AdError: function(a) {
        self.onVPAIDEvent('AdError');
      },
      AdLog: function() {
        self.onVPAIDEvent('AdLog');
      }
    };

    for (var eventName in self.eventCallbacks) {
      self.VPAIDAd.subscribe(self.eventCallbacks[eventName], eventName);
    }

    self.VPAIDAd.handshakeVersion("2.0");

    self.VPAIDAd.initAd(
      player.width,
      player.height,
      "normal",
      0, {
        AdParameters: self.linearNode.adParameters
      },
      self.environmentVars);
  };

  this.destroy = function() {
    self.destroyed = true;
    if (self.VPAIDAd) {
      for (var eventName in self.callbacks) {
        try {
          self.VPAIDAd.unsubscribe(eventName);
        } catch (e) {}
      }

      try {
        self.VPAIDAd.stopAd();
        self.VPAIDAd = null;
      } catch (e) {}
    }

    if (self.vastObjectManager) {
      self.vastObjectManager = null;
    }

    if (self.vpaidFrame) {
      try {
        self.vpaidFrame.parentNode.removeChild(self.vpaidFrame);
      } catch (e) {}
    }
  }
};
