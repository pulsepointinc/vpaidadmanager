package com.pulsepoint.ad {
	import com.pulsepoint.utils.MacroHelper;

	public class VastWrapper {
		var _linearNodes:Array = new Array;
		var _pixels:Object = {"impression": new Array, "creativeView": new Array, "start": new Array, "firstQuartile": new Array, "midpoint": new Array, "thirdQuartile": new Array, "complete": new Array, "click": new Array, "mute": new Array, "unmute": new Array, "pause": new Array, "resume": new Array, expand: new Array, collapse: new Array, acceptInvitation: new Array, close: new Array, "error": new Array, "progress": new Array};

		public function VastWrapper(wrapper:XML = null):void {
			setWrapper(wrapper);
		}

		public function setWrapper(wrapper:XML = null):void {
			if (wrapper) {
				var text:String = "";

				for each (var impression:XML in wrapper.Impression) {
					text = impression.text();
					_pixels.impression.push(text);
				}

				for each (var error:XML in wrapper.Error) {
					text = error.text();
					_pixels.error.push(text);
				}

				var creative:XML = wrapper.Creatives..Linear[0];

				if (creative && creative.TrackingEvents && creative.TrackingEvents.Tracking) {
					for each (var tracking:XML in creative.TrackingEvents.Tracking) {
						text = tracking.text();
						var event:String = tracking.@event.toString();
						if (event && _pixels[event]) {
							_pixels[event].push(text);
						}
					}
				}

				if (creative && creative.VideoClicks && creative.VideoClicks.ClickTracking) {
					for each (var clickTracking:XML in creative.VideoClicks.ClickTracking) {
						var clickTrackingUrl:String = clickTracking.text();

						clickTrackingUrl = MacroHelper.replaceMacro(clickTrackingUrl);

						_pixels.click.push(clickTrackingUrl);
					}
				}
			}
		}

		public function init(xml:XML):void {
			var id:String = String(xml.Ad.@id);
			for each (var inline:XML in xml.Ad.InLine) {
				var linear:VastLinear = new VastLinear(inline, id);
				linear.mergePixels(_pixels);
				_linearNodes.push(linear);
			}
		}

		public function get linearNodes():Array {
			return _linearNodes;
		}

		public function get pixels():Object {
			return _pixels;
		}
	}
}
