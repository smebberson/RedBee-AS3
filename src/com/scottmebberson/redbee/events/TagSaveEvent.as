package com.scottmebberson.redbee.events
{
	
	import flash.events.Event;
	
	public class TagSaveEvent extends Event
	{
		
		// event identifiers
		public static const TAG_SAVE:String = "TAG_SAVE";
			
		// private vars
		private var _tag:String;
		private var _success:Boolean;
		
		public function TagSaveEvent(tag:String, success:Boolean)
		{
			
			super(TAG_SAVE);
			
			_tag = tag;
			_success = success;
			
		}
		
		override public function clone():Event
		{
			return new TagSaveEvent(tag, success);
		}
		
		public function set tag(value:String) : void
		{
			_tag = value;
		}
		
		public function get tag() : String
		{
			return _tag;
		}
		
		public function set success(value:Boolean) : void
		{
			_success = value;
		}
		
		public function get success() : Boolean
		{
			return _success;
		}
		
	}
}