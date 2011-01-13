package com.scottmebberson.redbee
{
	import com.scottmebberson.redbee.events.TagSwipeEvent;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	public class RFIDReader extends Socket
	{
		
		/* private variables */
		private var _buffer:String = "";
		private var _host:String = "127.0.0.1";
		private var _port:uint = 5331;
		
		/* private constants */
		private static const EOL_DELIMITER : String = "\r\n>";
		
		public function RFIDReader(host:String='127.0.0.1', port:int=5331)
		{
			
			super(host, port);
			
			_host = host;
			_port = port;
			
			setupListeners();
			
		}
		
		/* private functions */
		private function setupListeners() : void
		{
			
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
			
		}
		
		private function socketDataHandler (event : ProgressEvent) : void
		{
			
			trace('RFIDReader: ' + event);
			
			var msg:String;
			var index:int;
			var data : String = this.readUTFBytes(this.bytesAvailable);
			
			_buffer += data;
			
			trace("RFIDReader: so far:" + _buffer);
			
			//loop through the buffer until it contains no more
			//end of message delimiter
			while((index = _buffer.indexOf(EOL_DELIMITER)) > -1)
			{
				//extract the message from the beginning to where the delimiter is
				//we don't include the delimiter
				msg = _buffer.substring(0, index);
				
				//remove the message from the buffer
				_buffer = _buffer.substring(index + 1);
				
				//trace out the message (or do whatever you want with it)
				parseResponse(msg);
				
				trace('RFIDReader: ' + msg);
				
			}
			
		}
		
		private function parseResponse (msg : String) : void
		{
			
			var positive : Boolean = (msg.indexOf('NACK') == -1) ? true : false;
			
			trace("RFIDReader: valid: " + positive.toString());
			
			// send out a RedBee Event
			trace('RFIDReader: tag: ' + msg.substr(6, 14));
			
			dispatchEvent(new TagSwipeEvent(msg.substr(6, 14), (positive == true) ? 1 : 0));
			
		}
		
	}
}