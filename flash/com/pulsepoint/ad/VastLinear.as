package com.pulsepoint.ad {
	import com.pulsepoint.utils.MacroHelper;
	import flash.external.ExternalInterface;

	public class VastLinear {
		var _adId:String = "";
		var _title:String = "";
		var _adSystem:String = "";
		var _clickThroughUrl:String = "";
		var _mediaFile:Object = {};
		var _adParameters:String = "";

		var _pixels:Object = {"impression": new Array, "creativeView": new Array, "start": new Array, "firstQuartile": new Array, "midpoint": new Array, "thirdQuartile": new Array, "complete": new Array, "click": new Array, "mute": new Array, "unmute": new Array, "pause": new Array, "resume": new Array, expand: new Array, collapse: new Array, acceptInvitation: new Array, close: new Array, "error": new Array, "progress": new Array};

		public function VastLinear(inline:XML, adId:String = null):void {
			_adId = adId;
			_title = inline.AdTitle.text();
			_adSystem = inline.AdSystem.text();

			var text:String = "";

			for each (var impression:XML in inline.Impression) {
				text = impression.text();
				_pixels.impression.push(text);
			}

			for each (var error:XML in inline.Error) {
				text = error.text();
				_pixels.error.push(text);
			}

			var creative:XML = inline.Creatives..Linear[0];

			if (creative && creative.TrackingEvents && creative.TrackingEvents.Tracking) {
				for each (var tracking:XML in creative.TrackingEvents.Tracking) {

					text = tracking.text();
					var event:String = tracking.@event.toString();
					if (event && _pixels[event]) {
						_pixels[event].push(text);
					}
				}
			}

			for each (var clickThrough:XML in creative.VideoClicks.ClickThrough) {
				var click:String = clickThrough.text();

				click = MacroHelper.replaceMacro(click);

				_clickThroughUrl = click;
			}

			for each (var clickTracking:XML in creative.VideoClicks.ClickTracking) {
				var clickTrackingUrl:String = clickTracking.text();

				clickTrackingUrl = MacroHelper.replaceMacro(clickTrackingUrl);

				_pixels.click.push(clickTrackingUrl);
			}

			_mediaFile.videoFiles = new Array();
			for each (var mediaFile:XML in creative.MediaFiles.MediaFile) {
				var file:String = mediaFile.text();

				var mediaType:String = mediaFile.@type;

				if (!mediaType || file === ""){
					continue;
				}

				switch(mediaType){
					case "video/x-flv":
					case "video/mp4":
					case "video/3gpp":
					case "video/quicktime":
						_mediaFile.videoFiles.push(file);
						break;
					case "application/x-shockwave-flash":
						_mediaFile.flashVpaid = file;
						break;
					case "application/javascript":
						_mediaFile.jsVpaid = file;
						break;
					default:
						break;
				}
			}

			_adParameters = inline.Creatives..Linear[0].AdParameters;
		}

		public function get clickThroughUrl():String {
			return _clickThroughUrl;
		}

		public function get adId():String {
			return _adId;
		}

		public function get title():String {
			return _title;
		}

		public function get adSystem():String {
			return _adSystem;
		}

		public function get mediaFile():Object {
			return _mediaFile;
		}

		public function get pixels():Object {
			return _pixels;
		}

		protected function addPixel(event:String, url:String):void {
			_pixels[event].push(url);
		}

		public function mergePixels(pixels:Object):void {
			for (var p:String in pixels) {
				for each (var pp:* in pixels[p]) {
					addPixel(p, pp);
				}
			}
		}

		public function get adParameters():String {
			return _adParameters;
		}
	}
}
