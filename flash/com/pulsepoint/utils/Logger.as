package com.pulsepoint.utils {
	import flash.external.ExternalInterface;
	import flash.utils.getQualifiedClassName;

	public class Logger {
		public static function log(source:*, msg:String):void {
			var classname:String = getQualifiedClassName(source);
			if (classname.indexOf("::") > 1) {
				classname = classname.split("::")[1];
			}
			trace(classname + ":" + msg);
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("console.log", classname + ":" + msg);
				} catch (e:Error) {
				}
			}
		}
	}
}
