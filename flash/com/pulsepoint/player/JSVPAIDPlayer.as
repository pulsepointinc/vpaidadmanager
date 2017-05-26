package com.pulsepoint.player {
	import com.pulsepoint.ad.VastLinear;
	import com.pulsepoint.page.ElementNode;
	import com.pulsepoint.utils.Logger;
	import com.pulsepoint.vpaid.IVPAID;
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;

	public class JSVPAIDPlayer extends Sprite implements IVPAID {
		private static const JS_SCRIPT:String =
		'		window.ppa = window.ppa || {};' +
		'		window.ppa.jsflashwrapper = window.ppa.jsflashwrapper || {};' +
		'		window.ppa.jsflashwrapper.ppaJSFlashWrapper___UID__ = {};' +
		'		var ppaJSFlashWrapper___UID__ = window.ppa.jsflashwrapper.ppaJSFlashWrapper___UID__;' +
		'		ppaJSFlashWrapper___UID__.player = window.ppa.videoPlayer[__UID__];' +
		'		ppaJSFlashWrapper___UID__.width = 0;' +
		'		ppaJSFlashWrapper___UID__.height = 0;' +

		'		ppaJSFlashWrapper___UID__.loadVPAID = function(url) {' +
		'		    ppaJSFlashWrapper___UID__.environmentVars = {};' +

		'		    var iframe = document.createElement(\'iframe\');' +
		'		    ppaJSFlashWrapper___UID__.iframe = iframe;' +

		'		    document.body.appendChild(iframe);' +
		'		    iframe.contentWindow.document.write(\'<body style="margin:0"><div id="slot"></div></body>\');' +

		'		    var vpaidLoader = iframe.contentWindow.document.createElement(\'script\');' +
		'		    vpaidLoader.src = url;' +

		'		    vpaidLoader.onload = function() {' +
		'		      ppaJSFlashWrapper___UID__.onVPAIDReady({' +
		'		        "getVPAIDAd": iframe.contentWindow.getVPAIDAd' +
		'		      });' +
		'		    };' +

		'		    vpaidLoader.onerror = function(e) {' +
		'					ppaJSFlashWrapper___UID__.onAdEvent(\'AdError\');' +
		'		    };' +

		'		    iframe.contentWindow.document.body.appendChild(vpaidLoader);' +

		'		    iframe.scrolling = \'no\';' +
		'		    iframe.style.display = \'none\';' +
		'		    iframe.style.position = \'absolute\';' +
		'		    iframe.style.top = "0px";' +
		'		    iframe.style.left = "0px";' +
		'		    iframe.frameBorder = \'0\';' +
		'		    iframe.setAttribute(\'frameBorder\', \'0\');' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.onVPAIDReady = function() {' +
		'		    var fn = ppaJSFlashWrapper___UID__.iframe.contentWindow.getVPAIDAd;' +
		'		    if (fn && typeof fn === \'function\') {' +
		'		        ppaJSFlashWrapper___UID__.environmentVars.slot =' +
		'		            ppaJSFlashWrapper___UID__.iframe.contentWindow.document.getElementById(\'slot\');' +

		'		        ppaJSFlashWrapper___UID__.environmentVars.videoSlot = document.createElement(\'video\');' +
		'		        ppaJSFlashWrapper___UID__.environmentVars.slot.appendChild(ppaJSFlashWrapper___UID__.environmentVars.videoSlot);' +

		'		        ppaJSFlashWrapper___UID__.VPAIDAd = fn();' +
		'		        ppaJSFlashWrapper___UID__.sendEvent({' +
		'		            event: \'jsvpaidready\'' +
		'		        });' +

		'		        var callbacks = {' +
		'		            AdStarted: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdStarted\');' +
		'		            },' +
		'		            AdStopped: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdStopped\');' +
		'		            },' +
		'		            AdSkipped: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdSkipped\');' +
		'		            },' +
		'		            AdLoaded: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdLoaded\');' +
		'		                ppaJSFlashWrapper___UID__.iframe.style.display = \'block\';' +
		'		            },' +
		'		            AdLinearChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdLinearChange\');' +
		'		            },' +
		'		            AdSizeChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdSizeChange\');' +
		'		            },' +
		'		            AdExpandedChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdExpandedChange\');' +
		'		            },' +
		'		            AdSkippableStateChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdSkippableStateChange\');' +
		'		            },' +
		'		            AdDurationChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdDurationChange\');' +
		'		            },' +
		'		            AdRemainingTimeChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdRemainingTimeChange\');' +
		'		            },' +
		'		            AdVolumeChange: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVolumeChange\');' +
		'		            },' +
		'		            AdImpression: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdImpression\');' +
		'		            },' +
		'		            AdClickThru: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdClickThru\');' +
		'		            },' +
		'		            AdInteraction: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdInteraction\');' +
		'		            },' +
		'		            AdVideoStart: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVideoStart\');' +
		'		            },' +
		'		            AdVideoFirstQuartile: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVideoFirstQuartile\');' +
		'		            },' +
		'		            AdVideoMidpoint: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVideoMidpoint\');' +
		'		            },' +
		'		            AdVideoThirdQuartile: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVideoThirdQuartile\');' +
		'		            },' +
		'		            AdVideoComplete: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdVideoComplete\');' +
		'		            },' +
		'		            AdUserAcceptInvitation: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdUserAcceptInvitation\');' +
		'		            },' +
		'		            AdUserMinimize: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdUserMinimize\');' +
		'		            },' +
		'		            AdUserClose: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdUserClose\');' +
		'		            },' +
		'		            AdPaused: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdPaused\');' +
		'		            },' +
		'		            AdPlaying: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdPlaying\');' +
		'		            },' +
		'		            AdError: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdError\');' +
		'		            },' +
		'		            AdLog: function() {' +
		'		                ppaJSFlashWrapper___UID__.onAdEvent(\'AdLog\');' +
		'		            }' +
		'		        };' +

		'		        for (var eventName in callbacks) {' +
		'		            ppaJSFlashWrapper___UID__.VPAIDAd.subscribe(callbacks[eventName], eventName);' +
		'		        }' +
		'		    }' +
		'		};' +


		'		ppaJSFlashWrapper___UID__.reposition = function() {' +
		'		    if (ppaJSFlashWrapper___UID__ && ppaJSFlashWrapper___UID__.player) {' +
		'		        var divpos = ppaJSFlashWrapper___UID__.player.getBoundingClientRect();' +
		'		        if (ppaJSFlashWrapper___UID__.environmentVars && ppaJSFlashWrapper___UID__.environmentVars.videoSlot) {' +
		'		            try {' +
		'		                ppaJSFlashWrapper___UID__.environmentVars.videoSlot.width = ppaJSFlashWrapper___UID__.width;' +
		'		                ppaJSFlashWrapper___UID__.environmentVars.videoSlot.height = ppaJSFlashWrapper___UID__.height;' +
		'		            } catch (e) {}' +
		'		        }' +

		'		        if (ppaJSFlashWrapper___UID__.iframe) {' +
		'		            try {' +
		'		                ppaJSFlashWrapper___UID__.iframe.style.width = ppaJSFlashWrapper___UID__.width + \'px\';' +
		'		                ppaJSFlashWrapper___UID__.iframe.style.height = ppaJSFlashWrapper___UID__.height + \'px\';' +
		'		                ppaJSFlashWrapper___UID__.iframe.style.top = window.scrollY + divpos.top + \'px\';' +
		'		                ppaJSFlashWrapper___UID__.iframe.style.left = window.scrollX + divpos.left + \'px\';' +
		'		            } catch (e) {}' +
		'		        }' +
		'		    }' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.sendEvent = function(data) {' +
		'		    if (ppaJSFlashWrapper___UID__ && ppaJSFlashWrapper___UID__.player) {' +
		'		        ppaJSFlashWrapper___UID__.player.onJSVPAIDEvent(data);' +
		'		    }' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.initAd =' +
		'		    function(data) {' +
		'		        ppaJSFlashWrapper___UID__.width = data.width;' +
		'		        ppaJSFlashWrapper___UID__.height = data.height;' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.initAd(' +
		'		            data.width,' +
		'		            data.height,' +
		'		            data.viewMode,' +
		'		            data.desiredBitrate,' +
		'		            data.creativeData,' +
		'		            ppaJSFlashWrapper___UID__.environmentVars);' +
		'		    };' +

		'		ppaJSFlashWrapper___UID__.onAdEvent = function(eventName) {' +
		'		    ppaJSFlashWrapper___UID__.sendEvent({' +
		'		        event: eventName' +
		'		    });' +

		'		    switch (eventName) {' +
		'		        case \'AdStarted\':' +
		'		            ppaJSFlashWrapper___UID__.reposition();' +
		'		            break;' +
		'		    }' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.startAd = function() {' +
		'		    try {' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.startAd();' +
		'		    } catch (e) {}' +

		'		    ppaJSFlashWrapper___UID__.reposition();' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.pauseAd = function() {' +
		'		  try {' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.pauseAd();' +
		'		    } catch (e) {}' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.resumeAd = function() {' +
		'		    try {' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.resumeAd();' +
		'		    } catch (e) {}' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.stopAd = function() {' +
		'		    try {' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.stopAd();' +
		'		    } catch (e) {}' +

		'		    ppaJSFlashWrapper___UID__.cleanup();' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.cleanup = function() {' +
		'		    ppaJSFlashWrapper___UID__.iframe.parentNode.removeChild(ppaJSFlashWrapper___UID__.iframe);' +
		'		    ppaJSFlashWrapper___UID__ = null;' +
		'		};' +

		'		ppaJSFlashWrapper___UID__.resizeAd = function(width, height, viewMode) {' +
		'		    ppaJSFlashWrapper___UID__.width = width;' +
		'		    ppaJSFlashWrapper___UID__.height = height;' +
		'		    if (ppaJSFlashWrapper___UID__ && ppaJSFlashWrapper___UID__.player) {' +
		'		        ppaJSFlashWrapper___UID__.VPAIDAd.resizeAd(width, height, viewMode);' +
		'		        ppaJSFlashWrapper___UID__.reposition();' +
		'		    }' +
		'		};' +

		'		window.addEventListener(\'resize\', ppaJSFlashWrapper___UID__.reposition);' +
		'		window.addEventListener(\'scroll\', ppaJSFlashWrapper___UID__.reposition);' +
		'		document.addEventListener(\'DOMNodeInserted\', ppaJSFlashWrapper___UID__.reposition);' +
		'		ppaJSFlashWrapper___UID__.loadVPAID(\'__MEDIA_FILE__\');';

		var _elementNode:ElementNode = ElementNode.getInstance();
		private var _linearNode:VastLinear;
		private var _mediaFile:String;
		private var _initAdWidth:Number;
		private var _initAdHeight:Number;
		private var _viewMode:String;
		private var _desiredBitrate:Object;
		private var _creativeData:String;
		private var _duration:Number = 0;

		public function JSVPAIDPlayer(linearNode:VastLinear, initAdWidth:Number, initAdHeight:Number) {
			_linearNode = linearNode;
			_mediaFile = linearNode.mediaFile.jsVpaid;
			_initAdWidth = initAdWidth;
			_initAdHeight = initAdHeight;

			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback("onJSVPAIDEvent", onJSVPAIDEvent);
					var jsScript:String = JS_SCRIPT.split("__UID__").join(_elementNode.uid).split("__MEDIA_FILE__").join(_mediaFile);
					ExternalInterface.call("eval", jsScript);
				} catch (e:Error) {
				}
			}
		}

		public function init():void {
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".checkPlayerNode", _elementNode.uid);
				} catch (e:Error) {
				}
			}
		}

		private function onJSVPAIDEvent(data:Object):void {
			switch (data.event) {
			case "jsvpaidready":
				handshakeVersion("2.0");
				initAd(_initAdWidth, _initAdHeight, "normal", 0, _linearNode.adParameters, null);
				break;
			case VPAIDEvent.AdLoaded:
				startAd();
				break;
			case VPAIDEvent.AdStopped:
				destroy();
			default:
				dispatchEvent(new VPAIDEvent(data.event, {}));
				break;
			}
		}

		public function get adData():String {
			return "";
		}

		public function get adIcons():Boolean {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdIcons");
		}

		public function get adLinear():Boolean {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdLinear");
		}

		public function get adWidth():Number {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdWidth");
		}

		public function get adHeight():Number {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdHeight");
		}

		public function get adExpanded():Boolean {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdExpanded");
		}

		public function get adSkippableState():Boolean {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdSkippableState");

		}

		public function get adRemainingTime():Number {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdRemainingTime");
		}

		public function get adDuration():Number {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdDuration");
		}

		public function get adVolume():Number {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdVolume");
		}

		public function set adVolume(value:Number):void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.setAdVolume", value);

		}

		public function get adCompanions():String {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.getAdCompanions");
		}

		public function handshakeVersion(version:String):String {
			return ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.handshakeVersion", version);
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Object = null, creativeData:Object = null, environmentVars:Object = null):void {
			_initAdWidth = width;
			_initAdHeight = height;
			_viewMode = viewMode;
			_desiredBitrate = desiredBitrate;
			_creativeData = String(creativeData);

			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".initAd", {width: _initAdWidth, height: _initAdHeight, viewMoide: _viewMode, desiredBitrate: _desiredBitrate, creativeData: {AdParameters: _creativeData}});
		}

		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			_initAdWidth = width;
			_initAdHeight = height;
			_viewMode = viewMode;

			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".resizeAd", _initAdWidth, _initAdHeight, _viewMode);
		}

		public function startAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".startAd");
		}

		public function stopAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".stopAd");
		}

		public function pauseAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".pauseAd");

		}

		public function resumeAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".resumeAd");
		}

		public function expandAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.expandAd");
		}

		public function collapseAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.collapseAd");
		}

		public function skipAd():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".VPAIDAd.skipAd");
		}

		public function setDuration(value:Number) {
			_duration = value;
		}

		public function getDuration():Number {
			return _duration;
		}

		public function resumeVideo():void {
			try {
				this.resumeAd();
			} catch (e:Error) {
			}
		}

		public function pauseVideo():void {
			try {
				this.pauseAd();
			} catch (e:Error) {
			}
		}

		public function stopVideo():void {
			try {
				this.stopAd();
			} catch (e:Error) {
			}
		}

		public function setSize(width:Number, height:Number):void {
			try {
				this.resizeAd(width, height, "normal");
			} catch (e:Error) {
			}
		}

		public function setVolume(num:Number):void {
			try {
				this.adVolume = num;
			} catch (e:Error) {
			}
		}

		public function getVolume():Number {
			try {
				return this.adVolume;
			} catch (e:Error) {
			}

			return 1;
		}

		public function destroy():void {
			ExternalInterface.call("ppaJSFlashWrapper_" + _elementNode.uid + ".cleanup");
		}
	}
}
