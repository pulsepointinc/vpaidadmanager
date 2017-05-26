package com.pulsepoint.player {
	import com.pulsepoint.ad.VastLinear;
	import com.pulsepoint.utils.Logger;
	import com.pulsepoint.vpaid.IVPAID;
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;

	public class VPAIDPlayer extends Sprite implements IVPAID {
		private var _vpaidLoader:Loader;
		private var _linearNode:VastLinear;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _vpaid:*;

		public function VPAIDPlayer(vpaidLoader:Loader, linearNode:VastLinear, width:Number, height:Number) {
			_vpaidLoader = vpaidLoader;
			_linearNode = linearNode;
			_vpaid = Object(_vpaidLoader.content).getVPAID();
			_width = width;
			_height = height;

			addChild(_vpaidLoader);

			try {
				addChild(_vpaid);
			} catch (e:Error) {
			}
		}

		public function init():void {
			try {
				_vpaid.addEventListener(VPAIDEvent.AdLoaded, onAdLoaded);
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

				_vpaid.handshakeVersion("1.1.0");

				initAd(_width, _height, "normal", 0, _linearNode.adParameters, null);
			} catch (e:Error) {
			}
		}

		public function handshakeVersion(playerVPAIDVersion:String):String {
			if (_vpaid) {
				return _vpaid.handshakeVersion(playerVPAIDVersion);
			}

			return "1.1.0";
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Object = null, creativeData:Object = null, environmentVars:Object = null):void {
			if (_vpaid) {
				_vpaid.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
			}
		}

		protected function onAdLoaded(e:Event):void {
			Logger.log(this, "onAdLoaded");

			try {
				_vpaid.startAd();
			} catch (e:Error) {
			}
		}

		protected function onVPAIDEvent(e:Event):void {
			var data:Object = {};

			if (Object(e).hasOwnProperty("data")) {
				data = Object(e).data;
			}

			dispatchEvent(new VPAIDEvent(e.type, data));
		}

		public function startAd():void {
			try {
				_vpaid.startAd();
			} catch (e:Error) {
			}
		}

		public function resumeAd():void {
			try {
				_vpaid.resumeAd();
			} catch (e:Error) {
			}
		}

		public function pauseAd():void {
			try {
				_vpaid.pauseAd();
			} catch (e:Error) {
			}
		}

		public function stopAd():void {
			try {
				_vpaid.stopAd();
			} catch (e:Error) {
			}
		}

		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			try {
				_vpaid.resizeAd(width, height, "normal");
			} catch (e:Error) {
			}
		}

		public function expandAd():void {
			if (_vpaid) {
				_vpaid.expandAd();
			}
		}

		public function collapseAd():void {
			if (_vpaid) {
				_vpaid.collapseAd();
			}
		}

		public function get adLinear():Boolean {
			if (_vpaid) {
				return _vpaid.adLinear;
			}

			return true;
		}

		public function get adExpanded():Boolean {
			if (_vpaid) {
				return _vpaid.adExpanded;
			}

			return true;
		}

		public function get adRemainingTime():Number {
			if (_vpaid) {
				return _vpaid.adRemainingTime;
			}

			return -2;
		}

		public function get adVolume():Number {
			if (_vpaid) {
				return _vpaid.adVolume;
			}

			return 1;
		}

		public function set adVolume(value:Number):void {
			if (_vpaid) {
				_vpaid.adVolume = value;
			}
		}

		public function destroy():void {
			try {
				_vpaid.removeEventListener(VPAIDEvent.AdLoaded, onAdLoaded);
				_vpaid.removeEventListener(VPAIDEvent.AdError, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdImpression, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdStopped, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdPaused, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdPlaying, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdStarted, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdVideoStart, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdLog, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdLinearChange, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdUserClose, onVPAIDEvent);
				_vpaid.removeEventListener(VPAIDEvent.AdClickThru, onVPAIDEvent);

				this.stopAd();
			} catch (e:Error) {
			}
		}
	}
}
