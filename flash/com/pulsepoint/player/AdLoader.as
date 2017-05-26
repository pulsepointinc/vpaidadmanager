package com.pulsepoint.player {
	import com.pulsepoint.MainPlayer;
	import com.pulsepoint.ad.VastLinear;
	import com.pulsepoint.ad.VastWrapper;
	import com.pulsepoint.player.VPAIDPlayer;
	import com.pulsepoint.player.VideoPlayer;
	import com.pulsepoint.utils.Logger;
	import com.pulsepoint.utils.MacroHelper;
	import com.pulsepoint.utils.Tracker;
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.external.ExternalInterface;

	public class AdLoader extends Sprite {
        public static const EXIT:String = "ADLOADER_EXIT";

		private var _callback:Function = null;
		private var _endPoint:String;
		private var _vastWrapper:VastWrapper;
		private var _linearNode:VastLinear;
		private var _player:*;

		private var _tagLoader:Loader;
		private var _vpaidLoader:Loader;
		private var _creativeData:Object;

		private var _destroyed:Boolean = false;

    private var _impressionFired:Boolean = false;
    private var _cachedEvents:Array = new Array();

		public function AdLoader(endPoint:String, vpaidEventCallback:Function):void {
			_endPoint = endPoint;
			_callback = vpaidEventCallback;
		}

		public function init():void{
            if (_endPoint.indexOf("data:application/xml") === 0) {
                var xmlString:String = _endPoint.substring(21);
                onAdLoadComplete(null, xmlString);
            }else{
                var filteredUrl:String = MacroHelper.replaceMacro(_endPoint);
                Security.allowDomain(filteredUrl);

                var loader = new URLLoader();
                loader.addEventListener(Event.COMPLETE, onAdLoadComplete);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onAdLoadFailed);
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onAdLoadFailed);

                loader.load(new URLRequest(filteredUrl));
            }
		}

		private function onAdLoadFailed(event:Event):void {
			MacroHelper.errorCode = 100;
			dispatchEvent(new Event(EXIT));
		}

		private function onAdLoadComplete(event:Event, xmlString:String = null):void {
			if (_destroyed) {
				return;
			}

			var vastXML:XML = null;
			if (event === null){
				vastXML = XML(decodeURIComponent(xmlString));
			}else{
				vastXML = XML(event.currentTarget.data);
			}

			if (!vastXML && !vastXML.Ad) {
				if (vastXML.Error){
					MacroHelper.errorCode = 100;
					var errorPixels:Array = new Array;
					for each (var error:XML in vastXML.Error) {
						var text:String = error.text();
						errorPixels.push(text);
					}

					Tracker.fire(errorPixels);
				}
				onAdLoadFailed(null);
				return;
			}

			if (!_vastWrapper) {
				_vastWrapper = new VastWrapper();
			}

			var hasWrapper:Boolean = false;
			var wrapperUrl:String = "";

			for each (var wrapper:XML in vastXML.Ad.Wrapper) {
				hasWrapper = true;
				wrapperUrl = MacroHelper.replaceMacro(wrapper.VASTAdTagURI.text());

				Security.allowDomain(wrapperUrl);

				_vastWrapper.setWrapper(wrapper);
				break;
			}

			if (hasWrapper) {
				var loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onAdLoadComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onAdLoadFailed);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onAdLoadFailed);
				Logger.log(this, "loading ad from " + wrapperUrl);
				loader.load(new URLRequest(wrapperUrl));
				return;
			} else {
				_vastWrapper.init(vastXML);
			}

			for each (var linear:VastLinear in _vastWrapper.linearNodes) {
				_linearNode = linear;

				if (_linearNode.mediaFile.videoFiles && _linearNode.mediaFile.videoFiles.length >= 1){
					onMediaReady(null);
				} else if (_linearNode.mediaFile.flashVpaid) {
					var ldrContext:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
					ldrContext.checkPolicyFile = true;

					var mediaUrl:String = MacroHelper.replaceMacro(_linearNode.mediaFile.flashVpaid);
					Security.allowDomain(mediaUrl);

					_vpaidLoader = new Loader();
					_vpaidLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMediaReady);
					_vpaidLoader.addEventListener(IOErrorEvent.IO_ERROR, onAdLoadFailed);
					_vpaidLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onAdLoadFailed);
					_vpaidLoader.load(new URLRequest(mediaUrl));
				} else if (_linearNode.mediaFile.jsVpaid) {
					onMediaReady(null, true);
				}
				break;
			}

			if (_linearNode == null) {
				onAdLoadFailed(null);
			}
		}

		private function onMediaReady(event:Event = null, isJSVPAID:Boolean = false):void {
			if (event) {
				_player = new VPAIDPlayer(_vpaidLoader, _linearNode, MainPlayer.getInstance().width, MainPlayer.getInstance().height);
			} else if (isJSVPAID) {
				_player = new JSVPAIDPlayer(_linearNode, MainPlayer.getInstance().width, MainPlayer.getInstance().height);
			} else {
				if (_linearNode.mediaFile.videoFiles.length)
				_player = new VideoPlayer(_linearNode, MainPlayer.getInstance().width, MainPlayer.getInstance().height);
			}

			_player.addEventListener(VPAIDEvent.AdImpression, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdStopped, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdPaused, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdPlaying, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdStarted, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdVideoStart, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdLog, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdLinearChange, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdUserClose, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdClickThru, onVPAIDEvent);
			_player.addEventListener(VPAIDEvent.AdError, onAdLoadFailed);

			_player.init();
		}

		private function onVPAIDEvent(event:VPAIDEvent):void {
        switch(event.type){
            case VPAIDEvent.AdError:
								MacroHelper.errorCode = 901;
                dispatchEvent(new Event(EXIT));
                return;
            case VPAIDEvent.AdImpression:
                _impressionFired = true;
								_callback(event);
                for(var i:int = 0; i<_cachedEvents.length; i++){
                    if (_callback != null) {
                        _callback(_cachedEvents[i]);
                    }
                }
                return;
            default:
                break;
        }

        if (!_impressionFired){
            _cachedEvents.push(event);
        }else {
            if (_callback != null) {
                _callback(event);
            }
        }
		}

		public function get player():* {
			return _player;
		}

		public function get vastWrapper():VastWrapper {
			return _vastWrapper;
		}

		public function get linearNode():VastLinear {
			return _linearNode;
		}

		public function destroy():void {
			_destroyed = true;

			if (_vpaidLoader) {
				_vpaidLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onMediaReady);
				_vpaidLoader.removeEventListener(IOErrorEvent.IO_ERROR, onAdLoadFailed);
				_vpaidLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onAdLoadFailed);

				_vpaidLoader.unload();
			}

			if (_player) {
				_player.destroy();

				_player.removeEventListener(VPAIDEvent.AdImpression, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdStopped, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdPaused, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdPlaying, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdStarted, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdVideoStart, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdLog, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdLinearChange, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdUserClose, onVPAIDEvent);
				_player.removeEventListener(VPAIDEvent.AdClickThru, onVPAIDEvent);
        _player.removeEventListener(VPAIDEvent.AdError, onAdLoadFailed);

				try {
					_player.stop();
				} catch (e:Error) {
				}
			}

			_vpaidLoader = null;
			_player = null;
		}

	}
}
