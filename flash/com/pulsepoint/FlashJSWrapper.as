package com.pulsepoint {
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.Security;

	public class FlashJSWrapper extends Sprite {
		private var _vpaidLoader:Loader;
		private var _vpaid:*;
		private var _callback:String;

		public function FlashJSWrapper():void {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			if (this.loaderInfo.parameters) {
				if (this.loaderInfo.parameters.callback && this.loaderInfo.parameters.callback != "") {
				_callback = this.loaderInfo.parameters.callback;
			}

			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback("loadWrapper", loadWrapper);
					ExternalInterface.addCallback("handshakeVersion", handshakeVersion);
					ExternalInterface.addCallback("initAd", initAd);
					ExternalInterface.addCallback("getAdRemainingTime", getAdRemainingTime);
					ExternalInterface.addCallback("getAdVolume", getAdVolume);
					ExternalInterface.addCallback("setAdVolume", setAdVolume);
					ExternalInterface.addCallback("resizeAd", resizeAd);
					ExternalInterface.addCallback("startAd", startAd);
					ExternalInterface.addCallback("stopAd", stopAd);
					ExternalInterface.addCallback("pauseAd", pauseAd);
					ExternalInterface.addCallback("resumeAd", resumeAd);

					callback("wrapperLoaded", {});
				} catch (e:Error) {
				}
			}
		}
	}

		private function callback(eventName:String, data:Object):void{
			if (!_callback){
				return;
			}

			if (ExternalInterface.available) {
				try {
					ExternalInterface.call(_callback, eventName, data);
				} catch (e:Error) {
				}
			}
		}

		public function loadWrapper(url:String):void {
			Security.allowDomain(url)

			_vpaidLoader = new Loader();
			_vpaidLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onWrapperLoaded);
			_vpaidLoader.addEventListener(IOErrorEvent.IO_ERROR, onWrapperFailed);
			_vpaidLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onWrapperFailed);
			_vpaidLoader.load(new URLRequest(url));
		}

		private function onWrapperLoaded(event:Event):void {
			addChild(_vpaidLoader);
			_vpaid = Object(_vpaidLoader.content).getVPAID();
			_vpaid.addEventListener(VPAIDEvent.AdLoaded, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdError, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdImpression, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdStopped, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdPaused, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdPlaying, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdStarted, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdVideoStart, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdLog, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdLinearChange, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdUserClose, onVPAIDEvent);
			_vpaid.addEventListener(VPAIDEvent.AdClickThru, onVPAIDEvent);

			callback("wrapperReady", {});
		}

		private function onWrapperFailed(event:Event):void {
			callback(VPAIDEvent.AdError, {});
		}

		public function handshakeVersion(version:String):String {
			if (_vpaid) {
				return _vpaid.handshakeVersion(version);
			}
			return "1.0.1";
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Object = null, creativeData:Object = null, environmentVars:Object = null):void {
			if (_vpaid) {
				_vpaid.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
			}
		}

		protected function onVPAIDEvent(e:Event):void {
			var data:Object = {};

			if (Object(e).hasOwnProperty("data")) {
				data = Object(e).data;
			}

			if (!data) data = { };

			data.event = e.type;

			callback(e.type, {});
		}

		public function getAdRemainingTime():Number {
			if (_vpaid) {
				return _vpaid.adRemainingTime;
			}

			return -2;
		}

		public function getAdVolume():Number {
			if (_vpaid) {
				return _vpaid.adVolume;
			}

			return 1;
		}


		public function setAdVolume(value:Number):void {
			if (_vpaid) {
				_vpaid.adVolume = value;
			}
		}

		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			if (_vpaid) {
				_vpaid.resizeAd(width, height, viewMode);
			}
		}

		public function startAd():void {
			if (_vpaid) {
				_vpaid.startAd();
			}
		}

		public function stopAd():void {
			if (_vpaid) {
				_vpaid.stopAd();
			}
		}

		public function pauseAd():void {
			if (_vpaid) {
				_vpaid.pauseAd();
			}
		}

		public function resumeAd():void {
			if (_vpaid) {
				_vpaid.resumeAd();
			}
		}
	}
}
