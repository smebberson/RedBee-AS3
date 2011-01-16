package com.scottmebberson.redbee
{
	
	import com.scottmebberson.redbee.events.RedBeeEvent;
	import com.scottmebberson.redbee.events.TagSwipeEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	public class RFIDReader extends Socket
	{
		
		/* private variables */
		private var _buffer:String = "";
		private var _host:String = "127.0.0.1";
		private var _port:uint = 5331;
		
		/* private variables */
		private var _previousCommunication:String;
		private var _firmwareVersion:String;
		
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
			
			var msg:String;
			var index:int;
			var data : String = this.readUTFBytes(this.bytesAvailable);
			
			_buffer += data;
			
			//loop through the buffer until it contains no more
			//end of message delimiter
			while((index = _buffer.indexOf(EOL_DELIMITER)) > -1)
			{
				//extract the message from the beginning to where the delimiter is
				//we don't include the delimiter
				msg = _buffer.substring(0, index);
				
				// reset the buffer
				_buffer = '';
				
				//trace out the message (or do whatever you want with it)
				parseResponse(msg);
				
			}
			
		}
		
		private function parseResponse (msg : String) : void
		{
			
			// first things first, check for an asynchronous packet
			// it should contain a packet event identifier followed by :(N)ACK XXX  XXX  XXX  XXX  XXX
			// packet event identifiers are:
			// T: for tag swipe
			// DT: for tag delete
			// ST: for tag save
			// X:<PinId>: for pin changed
			// X:P:<value>: for RF power enable/disabled
			
			if (msg.search(/^[TDSX:]{2,4}/) >= 0) {
				processAsynchronousEvent(msg);
			} else {
				processSynchronousEvent(msg);
			}
			
		}
		
		private function processAsynchronousEvent (msg : String) : void
		{
			
			// asynchronous packet event identifiers are:
			// T: for tag swipe
			// DT: for tag delete
			// ST: for tag save
			// X:<PinId>: for pin changed
			// X:P:<value>: for RF power enable/disabled
			
			var id:String = msg.replace(/^(T|DT|ST):N?ACK ([0-9 ]+)$/, '$2');
			var valid:int = (msg.indexOf('NACK') == -1) ? 1 : 0;
			
			if (msg.search(/^T:/) == 0) {
				dispatchEvent(new TagSwipeEvent(id, valid));
			}
			
		}
		
		private function processSynchronousEvent (msg : String) : void
		{
			
			trace('RFIDReader:processSynchronousEvent: ' + msg);
			
			if (_previousCommunication.search(/^fw/) == 0) {
				dispatchEvent(new RedBeeEvent(RedBeeEvent.FIRMWARE_VERSION, msg));
			}
			
		}
		
		// public methods
		public function requestFirmwareVersion () : void
		{
			
			// make sure we're still connected
			if (!connected) {
				
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, true, true, "You must be connected to a local TCP proxy to send a command to the RedBee RFID Reader."));
				return;
				
			}
			
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
			
			_previousCommunication = 'fw\r';
			
			writeUTFBytes(_previousCommunication);
			
			flush();
			
		}
		
		public function getFirmwareVersion () : String
		{
			
			return _firmwareVersion;
			
		}
		
	}
}