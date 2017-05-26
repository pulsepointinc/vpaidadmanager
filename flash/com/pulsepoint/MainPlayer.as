package com.pulsepoint {
	import JSON;
	import com.pulsepoint.ad.VastLinear;
	import com.pulsepoint.ad.VastWrapper;
	import com.pulsepoint.page.ElementNode;
	import com.pulsepoint.player.AdLoader;
	import com.pulsepoint.utils.ExternalScripts;
	import com.pulsepoint.utils.Logger;
	import com.pulsepoint.utils.MacroHelper;
	import com.pulsepoint.utils.Tracker;
	import com.pulsepoint.vpaid.IVPAID;
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	public class MainPlayer extends Sprite implements IVPAID {
		public static const DEFAULT_TIMEOUT:Number = 15000;

		private static var _instance:MainPlayer;
		private static var _elementNode:ElementNode = ElementNode.getInstance();
		private var _background:Sprite;

		private var _vastWrapper:VastWrapper;
		private var _linearNode:VastLinear;
		private var _player:*;

		public var _volume:Number = 1;

		private var _initAdWidth:Number = -1;
		private var _initAdHeight:Number = -1;

		private var _startFired:Boolean = false;

		private var _vpaidLoader:Loader;
		private var _creativeData:Object;
		private var _timeout:Number;

		private var _adWaitTimer:Number = -1;

		private var _ads:Array = [];
		private var _currentAd:AdLoader;

		private var _initAdVolume:Number = 1;

		private var _extScripts:ExternalScripts;

		public function MainPlayer():void {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			_instance = this;

			init();
		}

		private function init():void {
			_vastWrapper = null;
			_linearNode = null;

			_background = new Sprite();
			_background.graphics.beginFill(0x000000);
			_background.graphics.drawRect(0, 0, 1, 1);
			_background.graphics.endFill();

			addChild(_background);

			this.visible = false;
		}

		public function handshakeVersion(version:String):String {
			Logger.log(this, "handshakeVersion, version =" + version);
			return "1.0.1";
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Object = null, creativeData:Object = null, environmentVars:Object = null):void {
			Logger.log(this, "initAd, width=" + width + ",height=" + height + ",desiredBitrate=" + desiredBitrate + ",creativeData=" + creativeData + ",environmentVars=" + environmentVars);
			_creativeData = JSON.parse(creativeData as String);

			if (_creativeData.scripts && typeof _creativeData.scripts === "object"){
				_extScripts = new ExternalScripts(_creativeData.scripts);
			}

			_initAdWidth = width;
			_initAdHeight = height;

			if (_creativeData && !isNaN(_creativeData.timeoutMs)) {
				_timeout = _creativeData.timeoutMs;
			} else {
				_timeout = DEFAULT_TIMEOUT;
			}

			if (_creativeData && _creativeData.vastEndpoints && _creativeData.vastEndpoints.length > 0) {
				for (var i:Number = 0; i < _creativeData.vastEndpoints.length; i++) {
					var endPoint = _creativeData.vastEndpoints[i];
					_ads.push(new AdLoader(endPoint, onVPAIDEvent));
				}

				if (_ads.length === 0){
        	dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
				}else{
                    loadNextAd();
				}
			} else {
				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
			}
		}

		private function loadNextAd():void{
            if (_ads.length === 0){
                dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
				return;
            }

			_currentAd = _ads.shift();
			_currentAd.addEventListener(AdLoader.EXIT, onAdLoaderExit);
            _currentAd.init();

            _adWaitTimer = setTimeout(function() {
							MacroHelper.errorCode = 301;
							fireError();
            	_currentAd.destroy();
							_currentAd = null;
							loadNextAd();
            }, _timeout);
		}

		private function onAdLoaderExit(event:Event):void{
			if (_currentAd){
				fireError();
      	_currentAd.destroy();
        _currentAd = null;
			}
      loadNextAd();
		}

		private function onVPAIDEvent(event:VPAIDEvent):void {
			if (event.type == VPAIDEvent.AdImpression) {
        	clearTimeout(_adWaitTimer);

          if (_currentAd) {
              _currentAd.removeEventListener(AdLoader.EXIT, onAdLoaderExit);
              _player = _currentAd.player;
              _linearNode = _currentAd.linearNode;
          }else{
              dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
							return;
          }

				if (!_startFired) {
					_startFired = true;
					_extScripts.execute();
					Tracker.fire(_linearNode.pixels.impression);
					Tracker.fire(_linearNode.pixels.start);
					this.addChild(_player as DisplayObject);
					resizeAd(_initAdWidth, _initAdHeight, "normal");
					this.visible = true;

					dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));

					this.adVolume = _initAdVolume;
				}

				return;
			}

			switch (event.type) {
			case VPAIDEvent.AdVideoStart:
				Tracker.fire(_linearNode.pixels.creativeView);
				break;
			case VPAIDEvent.AdVideoFirstQuartile:
				Tracker.fire(_linearNode.pixels.firstQuartile);
				break;
			case VPAIDEvent.AdVideoMidpoint:
				Tracker.fire(_linearNode.pixels.midpoint);
				break;
			case VPAIDEvent.AdVideoThirdQuartile:
				Tracker.fire(_linearNode.pixels.thirdQuartile);
				break;
			case VPAIDEvent.AdVideoComplete:
				Tracker.fire(_linearNode.pixels.complete);
				break;
			case VPAIDEvent.AdClickThru:
				Tracker.fire(_linearNode.pixels.click);
				break;
			case VPAIDEvent.AdPaused:
				Tracker.fire(_linearNode.pixels.pause);
				break;
			case VPAIDEvent.AdPlaying:
				Tracker.fire(_linearNode.pixels.resume);
				break;
			case VPAIDEvent.AdExpandedChange:
				Tracker.fire(_linearNode.pixels.expand);
				break;
			case VPAIDEvent.AdUserMinimize:
				Tracker.fire(_linearNode.pixels.collapse);
				break;
			case VPAIDEvent.AdUserAcceptInvitation:
				Tracker.fire(_linearNode.pixels.acceptInvitation);
				break;
			case VPAIDEvent.AdUserClose:
				Tracker.fire(_linearNode.pixels.close);
				break;
				case VPAIDEvent.AdStopped:
					cleanup();
					break;
			default:
				break;
			}
			dispatchEvent(event);
		}

		override public function dispatchEvent(event:Event):Boolean {
			Logger.log(this, "dispatchEvent:" + event.type);

			if (event.type == "AdLog" && !Object(event).hasOwnProperty("data")) {
				return false;
			}

			return super.dispatchEvent(event);

		}

		public function getVPAID():Object {
			return this;
		}

		public function get adLinear():Boolean {
			if (_player) {
				return _player.adLinear;
			}

			return true;
		}

		public function get adExpanded():Boolean {
			if (_player) {
				return _player.adExpanded;
			}

			return false;
		}

		public function get adRemainingTime():Number {
			if (_player) {
				return _player.adRemainingTime;
			}

			return -2;
		}

		public function get adVolume():Number {
			if (_player) {
				return _player.adVolume;
			}

			return 1;
		}

		public function set adVolume(value:Number):void {
			if (value < 0){
				value = 0;
			}else if (value > 1){
				value = 1;
			}

			if (_player) {
				var oldVol:Number = _player.adVolume;

				if (oldVol == 0) {
					if (value > 0) {
						Tracker.fire(_linearNode.pixels.unmute);
					}
				} else {
					if (value == 0) {
						Tracker.fire(_linearNode.pixels.mute);
					}
				}

				_player.adVolume = value;
			}else {
				_initAdVolume = value;
			}
		}

		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			Logger.log(this, "resizeAd, width=" + width + ",height=" + height);

			_initAdWidth = width;
			_initAdHeight = height;

			if (_player) {
				_player.resizeAd(_initAdWidth, _initAdHeight, "normal");

			}

			_background.x = 0;
			_background.y = 0;
			_background.width = width;
			_background.height = height;
		}

		public function startAd():void {
			resizeAd(_initAdWidth, _initAdHeight, "normal");
			this.visible = true;
		}

		public function stopAd():void {
			if (_currentAd){
				if (!_startFired){
					MacroHelper.errorCode = 301;
					fireError();
				}
				_currentAd.destroy();
				_currentAd = null;
			}
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
		}

		public function pauseAd():void {
			if (_player) {
				_player.pauseAd();
			}
		}

		public function resumeAd():void {
			if (_player) {
				_player.resumeAd();
			}
		}

		public function expandAd():void {
			if (_player) {
				_player.expandAd();
			}
		}

		public function collapseAd():void {
			if (_player) {
				_player.collapseAd();
			}
		}

		override public function get width():Number {
			return _initAdWidth;
		}

		override public function get height():Number {
			return _initAdHeight;
		}

		public static function getInstance():MainPlayer {
			return _instance;
		}

		function fireError():void{
      if (_currentAd){
          var errorPixel:Array = new Array;
          if (_currentAd.linearNode){
            errorPixel = _currentAd.linearNode.pixels.error;
          }else if(_currentAd.vastWrapper){
            errorPixel = _currentAd.vastWrapper.pixels.error;
          }
					Tracker.fire(errorPixel);
      }
    };

		function cleanup():void{
			_extScripts.cleanup();
		}
	}
}
