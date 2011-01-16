package com.scottmebberson.redbee.events
{
	
	import flash.events.Event;
	
	public class RedBeeEvent extends Event
	{
		
		// event identifiers
		public static const FIRMWARE_VERSION:String = "FIRMWARE_VERSION"
			
		// private vars
		private var _value:String;
		
		public function RedBeeEvent(type : String, value : String)
		{
			
			super(type);
			
			_value = value;
			
		}
		
		override public function clone():Event
		{
			return new RedBeeEvent(type, value);
		}
		
		public function set value(val:String) : void
		{
			_value = val;
		}
		
		public function get value() : String
		{
			return _value;
		}
		
	}
}