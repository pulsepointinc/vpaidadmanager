window.ppa.jsvpaid.VastWrapper = function() {
  var self = this;

  this.classConstructor = arguments.callee;

  var DomHelper = window.ppa.jsvpaid.DomHelper;
  var MacroHelper = window.ppa.jsvpaid.MacroHelper;
  var VastLinear = window.ppa.jsvpaid.VastLinear;

  this.linearNodes = new Array();

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

  var retriedWithoutCred = false;

  this.xmlDoc;

  this.eventCallbacks = {};

  this.subscribe = function(callbackFunc, eventName, aContext) {
    var callBack = callbackFunc.bind(aContext);
    self.eventCallbacks[eventName] = callBack;
  };

  function triggerEvent(eventName) {
    if (eventName in self.eventCallbacks) {
      self.eventCallbacks[eventName](self);
    }
  };

  function loadDoc(url) {
    var xhttp;
    if (window.XMLHttpRequest) {
      // code for modern browsers
      xhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }

    xhttp.onreadystatechange = function() {
      if (xhttp.readyState == 4) {
        if (xhttp.status == 200) {
          var parser = new DOMParser();
          self.xmlDoc = parser.parseFromString(xhttp.responseText, "text/xml");
          setAd(self.xmlDoc);
        } else if (xhttp.status == 0 && !retriedWithoutCred) {
          retriedWithoutCred = true;
          xhttp.abort();
          xhttp.open("GET", url, true);
          xhttp.withCredentials = false;
          xhttp.send();
        } else {
          triggerEvent(self.classConstructor.DONE);
        }
      }
    };

    try {
      xhttp.open("GET", url, true);
      xhttp.withCredentials = true;
      retriedWithoutCred = false;
      xhttp.send();
    } catch (e) {
      triggerEvent(self.classConstructor.DONE);
    }
  };

  function setWrapper(wrapper) {
    var imps = wrapper.getElementsByTagName('Impression');
    for (var i = 0; i < imps.length; i++) {
      var text = DomHelper.getXMLNodeValue(imps[i]);
      self.pixels.impression.push(text);
    }

    var errors = wrapper.getElementsByTagName('Error');
    for (var i = 0; i < errors.length; i++) {
      var text = DomHelper.getXMLNodeValue(errors[i]);
      self.pixels.error.push(text);
    }

    var creatives = wrapper.getElementsByTagName('Creative');

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

      var clickTracking = creative.getElementsByTagName('ClickTracking');
      for (var i = 0; i < clickTracking.length; i++) {
        var clickTrackingUrl = DomHelper.getXMLNodeValue(clickTracking[i]);
        clickTrackingUrl = MacroHelper.replaceMacro(clickTrackingUrl);
        self.pixels.click.push(clickTrackingUrl);
      }
    }

    var adTagUrl = DomHelper.getXMLNodeValue(wrapper, "VASTAdTagURI");
    adTagUrl = MacroHelper.replaceMacro(adTagUrl);

    loadDoc(adTagUrl);
  };

  function setInLine(ad) {
    if (ad) {
      var inlines = ad.getElementsByTagName("InLine");
      for (var i = 0; i < inlines.length; i++) {
        var inline = inlines[i];
        var linear = new VastLinear(inline);
        linear.mergePixels(self.pixels);
        self.linearNodes.push(linear);
      }
    }

    triggerEvent(self.classConstructor.DONE);
  };

  function setAd(adNode) {
    try {
      if (adNode && adNode.nodeName != "Ad") {
        var ad = adNode.getElementsByTagName("Ad");
        if (ad.length > 0) {
          adNode = ad[0];
        }
      }

      var wrapper = adNode.getElementsByTagName("Wrapper");
    } catch (e) {
      triggerEvent(self.classConstructor.DONE);
      return;
    }

    if (adNode) {
      if (wrapper.length > 0) {
        setWrapper(adNode);
      } else {
        setInLine(adNode);
      }
    } else {
      triggerEvent(self.classConstructor.DONE);
    }
  };

  this.init = function(xml) {
    setAd(xml);
  };
};

window.ppa.jsvpaid.VastWrapper.DONE = "done";
