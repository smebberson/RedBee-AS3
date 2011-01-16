package com.scottmebberson.redbee.events
{
	
	import flash.events.Event;
	
	public class TagSwipeEvent extends Event
	{
		
		// event identifiers
		public static const TAG_SWIPE:String = "TAG_SWIPE"
			
		// private vars
		private var _tag:String;
		private var _valid:int;
		
		public function TagSwipeEvent(tag:String, valid:int)
		{
			
			super(TAG_SWIPE);
			
			_tag = tag;
			_valid = valid;
			
		}
		
		override public function clone():Event
		{
			return new TagSwipeEvent(tag, valid);
		}
		
		public function set tag(value:String) : void
		{
			_tag = value;
		}
		
		public function get tag() : String
		{
			return _tag;
		}
		
		public function set valid(value:int) : void
		{
			_valid = value;
		}
		
		public function get valid() : int
		{
			return _valid;
		}
		
	}
}