package com.pulsepoint.utils {
	import com.pulsepoint.MainPlayer;
	import flash.external.ExternalInterface;

	public class MacroHelper {
		private static var _errorCode:Number = 901;

		public static function replaceMacro(str:String):String {
			var temp:String = trim(str);
			var timestamp:String = String(new Date().getTime());
			temp = temp.split("[ERRORCODE]").join(_errorCode);
			temp = temp.split("[CACHEBUSTING]").join(timestamp);

			return temp;
		}

		public static function trim(str:String):String {
			if (str == null) {
				return "";
			}
			return str.replace(/^s+|\s+/g, "");
		}

		public static function set errorCode(val:Number):void{
			_errorCode = val;
		}

		public static function get errorCode():Number{
			return _errorCode;
		}
	}
}
