package com.pulsepoint.player {
	import com.pulsepoint.ad.VastLinear;
	import com.pulsepoint.utils.NavigatorUtils;
	import com.pulsepoint.utils.Tracker;
	import com.pulsepoint.vpaid.IVPAID;
	import com.pulsepoint.vpaid.VPAIDEvent;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class VideoPlayer extends Sprite implements IVPAID {
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _background:Sprite;
		private var _click:Sprite;

		private var _linearNode:VastLinear;
		private var _width:Number = 0;
		private var _height:Number = 0;

		private var _timer:Timer;
		private var _video:Video;
		private var _metaData:Object;
		private var _duration:Number = 0;

		private var _startFired:Boolean = false;
		private var _firstQuartileFired:Boolean = false;
		private var _midpointFired:Boolean = false;
		private var _thirdQuartileFired:Boolean = false;
		private var _completeFired:Boolean = false;

		public function VideoPlayer(linearNode:VastLinear, width:Number, height:Number) {
			_linearNode = linearNode;
			_width = width;
			_height = height;
		}

		public function init():void {
			_background = new Sprite();

			_background.graphics.beginFill(0x000000);
			_background.graphics.drawRect(0, 0, 1, 1);
			_background.graphics.endFill();
			addChild(_background);

			_netConnection = new NetConnection();
			_netConnection.connect(null);

			_netStream = new NetStream(_netConnection);
			_netStream.soundTransform = new SoundTransform(1);
			_netStream.client = {onMetaData: onMeta};
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onStatus, false, 0, true);

			_video = new Video(_width, _height);
			_video.smoothing = true;
			addChild(_video);

			_click = new Sprite();

			_click.graphics.beginFill(0x000000);
			_click.graphics.drawRect(0, 0, 1, 1);
			_click.graphics.endFill();
			_click.alpha = 0;
			addChild(_click);

			_timer = new Timer(500);
			_timer.addEventListener(TimerEvent.TIMER, onTimerUpdate);

			initAd(_width, _height, "normal", 0, _linearNode.adParameters, null);
		}

		public function handshakeVersion(playerVPAIDVersion:String):String {
			return "1.0.1";
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Object = null, creativeData:Object = null, environmentVars:Object = null):void {
			_width = width;
			_height = height;
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLoaded));
			startAd();
		}

		public function startAd():void {
			Security.allowDomain("*");
			_duration = 0;
			_video.attachNetStream(_netStream);
			_netStream.play(_linearNode.mediaFile.videoFiles[0]);

			_timer.start();
		}

		public function resumeAd():void {
			if (_netStream) {
				_netStream.resume();
				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));
			}
		}

		public function pauseAd():void {
			if (_netStream) {
				_netStream.pause();
				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));
			}
		}

		public function stopAd():void {
			_netStream.pause();
			_video.attachNetStream(null);
			_video.clear();
			_netStream.close();
			stopTimer();

			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onStatus);

			_netConnection.close();
			_netConnection = null;
			_netStream = null;
			_video = null;

			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
		}

		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			_width = width;
			_height = height;

			if (_metaData && _metaData.width && _metaData.height) {
				var nativeRatio:Number = _metaData.width / _metaData.height;
				var videoRatio:Number = _width / _height;
				var diff:Number = nativeRatio - videoRatio;

				if (diff > 0.0001) {
					_video.width = _width;
					_video.x = 0;
					var h:Number = Math.round(_metaData.height * _width / _metaData.width);
					_video.height = isNaN(h) ? _height : h;
					var y:Number = Math.round(((_height - _video.height) / 2));
					_video.y = isNaN(y) ? 0 : y;
				} else if (diff < -0.0001) {
					var w:Number = Math.round(_metaData.width * _height / _metaData.height);
					_video.width = isNaN(w) ? _width : w;
					var x:Number = Math.round((_width - _video.width) / 2);
					_video.x = isNaN(x) ? 0 : x;
					_video.height = _height;
					_video.y = 0;
				} else {
					_video.x = 0;
					_video.y = 0;
					_video.width = _width;
					_video.height = _height;
				}
			} else {
				_video.x = 0;
				_video.y = 0;
				_video.width = _width;
				_video.height = _height;
			}

			_background.x = 0;
			_background.y = 0;
			_background.width = _width;
			_background.height = _height;

			_click.x = 0;
			_click.y = 0;
			_click.width = _width;
			_click.height = _height;
		}

		private function onMeta(data:Object):void {
			_duration = Number(data.duration);
			_metaData = data;

			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));

			_click.addEventListener(MouseEvent.CLICK, onClick);
		}

		public function expandAd():void {
		}

		public function collapseAd():void {
		}

		public function get adLinear():Boolean {
			return true;
		}

		public function get adExpanded():Boolean {
			return true;
		}

		public function get adRemainingTime():Number {
			if (_duration > 0 && _netStream) {
				return _duration - _netStream.time;
			}

			return -2;
		}

		public function set adVolume(value:Number):void {
			if (_netStream) {
				_netStream.soundTransform = new SoundTransform(value);
			}
		}

		public function get adVolume():Number {
			if (_netStream) {
				return _netStream.soundTransform.volume;
			}

			return 0;
		}

		private function getAdTime():Number {
			if (_netStream) {
				return _netStream.time;
			}

			return -1;
		}

		private function getAdDuration():Number {
			return _duration;
		}

		private function getAdPercentage():Number {
			if (_netStream && _duration > 0) {
				return Number((_netStream.time / _duration).toFixed(2));
			}

			return -1;
		}

		private function onTimerUpdate(event:TimerEvent):void {
			if (!_netStream || _duration == 0) {
				return;
			}

			var currentTime:Number = _netStream.time;

			if (!_startFired) {
				_startFired = true;

				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoStart));
			}

			if (!_firstQuartileFired && (currentTime / _duration) > 0.25) {
				_firstQuartileFired = true;

				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoFirstQuartile));
			}

			if (!_midpointFired && (currentTime / _duration) > 0.5) {
				_midpointFired = true;

				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoMidpoint));
			}

			if (!_thirdQuartileFired && (currentTime / _duration) > 0.75) {
				_thirdQuartileFired = true;

				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoThirdQuartile));
			}
		}

		private function onClick(event:Event) {
			var targetURL:URLRequest = new URLRequest(_linearNode.clickThroughUrl);
			NavigatorUtils.navigateToURL(targetURL, "_blank");
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru));
		}

		private function onStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
			case "NetStream.Play.Start":
				break;

			case "NetStream.Buffer.Full":
				break;

			case "NetStream.Play.Stop":
				if (_thirdQuartileFired && !_completeFired) {
					_completeFired = true;
					dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoComplete));
				}
				stopAd();
				break;

			case "NetStream.Buffer.Empty":
				break;

			case "NetConnection.Connect.Success":
				break;

			case "NetStream.Play.StreamNotFound":
			case "NetConnection.Connect.Rejected":
				dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
				break;

			case "NetConnection.Connect.Closed":
				break;
			}
		}

		public function stopTimer():void {
			if (_timer) {
				_timer.stop();
				_timer == null;
			}
		}

		public function destroy():void {
		}
	}
}
