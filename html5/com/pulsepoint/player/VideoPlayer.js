window.ppa.jsvpaid.VideoPlayer = function(adNode) {
  var self = this;

  var MacroHelper = window.ppa.jsvpaid.MacroHelper;

  this.classConstructor = arguments.callee;

  this.adNode = adNode;
  this.slot = null;
  this.videoSlot = null;
  this.eventsCallbacks = {};

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

  this.lastQuartileIndex = 0;

  this.parameters = {};

  this.initAd = function(
    width,
    height,
    viewMode,
    desiredBitrate,
    creativeData,
    environmentVars) {
    self.attributes['width'] = width;
    self.attributes['height'] = height;
    self.attributes['viewMode'] = viewMode;
    self.attributes['desiredBitrate'] = desiredBitrate;
    self.slot = environmentVars.slot;
    self.videoSlot = environmentVars.videoSlot;

    self.parameters = creativeData.AdParameters;

    updateVideoSlot();
    self.videoSlot.addEventListener(
      'timeupdate',
      self.timeUpdateHandler.bind(self),
      false);
    self.videoSlot.addEventListener(
      'durationchange',
      function() {
        self.attributes['duration'] = self.videoSlot.duration;
        callEvent('AdDurationChange');
      },
      false);
    self.videoSlot.addEventListener(
      'ended',
      function() {
        self.stopAd();
      },
      false);
    callEvent('AdLoaded');
  };

  this.timeUpdateHandler = function() {
    if (self.lastQuartileIndex >= self.quartileEvents.length) {
      return;
    }

    var dur = self.videoSlot.duration;

    var percentPlayed =
      self.videoSlot.currentTime * 100.0 / dur;
    if (percentPlayed >= self.quartileEvents[self.lastQuartileIndex].value) {
      var lastQuartileEvent = self.quartileEvents[self.lastQuartileIndex].event;
      if (typeof self.eventsCallbacks[lastQuartileEvent] == "function") {
        self.eventsCallbacks[lastQuartileEvent]();
      }
      self.lastQuartileIndex += 1;
    }
  };

  function onClick() {
    try {
      var clickUrl = MacroHelper.replaceMacro(self.parameters.linearNode.clickThroughUrl);
      if (clickUrl && clickUrl.length > 0) {
        callEvent('AdClickThru');
        window.open(clickUrl, "_blank");
      }
    } catch (e) {}
  };

  function updateVideoSlot() {
    if (self.videoSlot == null) {
      self.videoSlot = document.createElement('video');
      self.slot.appendChild(self.videoSlot);
    }

    var click = document.createElement('div');
    self.slot.appendChild(click);
    click.style.width = "100%";
    click.style.height = "100%";
    click.style.left = "0px";
    click.style.top = "0px";
    click.style.position = "absolute";
    click.style.cursor = "pointer";
    click.addEventListener('mouseup', onClick, false);

    self.resizeAd(self.attributes['width'], self.attributes['height'], self.attributes['viewMode']);

    var foundSource = false;
    var videos = self.parameters.videos || [];
    for (var i = 0; i < videos.length; i++) {
      // Choose the first video with a supported mimetype.
      if (videos[i] != '') {
        self.videoSlot.setAttribute('src', videos[i]);
        foundSource = true;
        break;
      }
    }
    if (!foundSource) {
      callEvent('AdError');
    }
  };

  function callEvent(eventType) {
    if (eventType in self.eventsCallbacks) {
      if (typeof self.eventsCallbacks[eventType] == 'function') {
        self.eventsCallbacks[eventType]();
      }
    }
  };

  this.stopAd = function() {
    var callback = callEvent.bind(self);
    setTimeout(callback, 75, ['AdStopped']);
  };

  this.startAd = function() {
    self.videoSlot.play();

    callEvent('AdImpression');
    callEvent('AdStarted');
  };

  this.handshakeVersion = function(version) {
    return ('2.0');
  };

  this.setAdVolume = function(value) {
    self.attributes['volume'] = value;
    try {
      self.videoSlot.volume = value;
    } catch (e) {}
    callEvent('AdVolumeChanged');
  };

  this.getAdVolume = function() {
    return self.attributes['volume'];
  };

  this.resizeAd = function(width, height, viewMode) {
    self.attributes['width'] = width;
    self.attributes['height'] = height;
    self.attributes['viewMode'] = viewMode;
    self.videoSlot.setAttribute('width', self.attributes['width']);
    self.videoSlot.setAttribute('height', self.attributes['height']);
    callEvent('AdSizeChange');
  };

  this.pauseAd = function() {
    self.videoSlot.pause();
    callEvent('AdPaused');
  };

  this.resumeAd = function() {
    self.videoSlot.play();
    callEvent('AdPlaying');
  };

  this.expandAd = function() {
    self.attributes['expanded'] = true;
    //handle full screen here
    callEvent('AdExpanded');
  };

  this.getAdExpanded = function() {
    return self.attributes['expanded'];
  };

  this.getAdSkippableState = function() {
    return self.attributes['skippableState'];
  };

  this.collapseAd = function() {
    self.attributes['expanded'] = false;
  };

  this.skipAd = function() {
    var skippableState = self.attributes['skippableState'];
    if (skippableState) {
      callEvent('AdSkipped');
    }
  };

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
    return self.attributes['width'];
  };

  this.getAdHeight = function() {
    return self.attributes['height'];
  };

  this.getAdRemainingTime = function() {
    if (self.videoSlot.duration && self.videoSlot.duration > 0) {
      return self.videoSlot.duration - self.videoSlot.currentTime;
    }
    return 0;
  };

  this.getAdDuration = function() {
    return self.attributes['duration'];
  };

  this.getAdCompanions = function() {
    return self.attributes['companions'];
  };

  this.getAdIcons = function() {
    return self.attributes['icons'];
  };

  this.getAdLinear = function() {
    return self.attributes['linear'];
  };

  this.getVPAIDAd = function() {
    return self;
  };
};
