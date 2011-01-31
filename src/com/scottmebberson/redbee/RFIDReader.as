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
		
		private var _fw:String = null;
		private var _rst:String = null;
		private var _xb:int = -1;
		
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
			
			// find the correct synchronous event we're processing
			// then store the old value for caching, and fire the corresponding event
			
			if (_previousCommunication.search(/^fw/) == 0) {
				_fw = msg;
				dispatchEvent(new RedBeeEvent(RedBeeEvent.FW, msg));
			} else if (_previousCommunication.search(/^rst/) == 0) {
				_rst = msg;
				dispatchEvent(new RedBeeEvent(RedBeeEvent.RST, msg));
			} else if (_previousCommunication.search(/^xb/) == 0) {
				_xb = Number(msg);
				dispatchEvent(new RedBeeEvent(RedBeeEvent.XB, msg));
			}
			
		}
		
		// actually communicate with the RedBee device
		private function sendCommand (cmd : String) : void
		{	
			
			_previousCommunication = cmd;
			
			writeUTFBytes(_previousCommunication);
			
			flush();
			
		}
		
		/* *******************
			public methods
		******************* */
		
		// if '' is returned, it means the value is being requested from the device
		public function fw (cache:Boolean=false) : String
		{
			
			var sReturn:String = '';
			
			if (cache == true && _fw != null) {
				sReturn = _fw;
				return sReturn;
			}
			
			if (!connected) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, true, true, "You must be connected to a local TCP proxy to send a command to the RedBee RFID Reader."));
				return '';
			}
			
			sendCommand('fw\r');
			
			return sReturn;
			
		}
		
		// if '' is returned, it means the value is being requested from the device
		public function rst (cache:Boolean=false) : String
		{
			
			var sReturn:String = '';
			
			// if they've requested cache, but it doesn't exist yet
			// we'll return '' and request it
			if (cache == true && _rst != null)  {
				sReturn = _rst;
				return sReturn;
			}
			
			// make sure we're still connected
			if (!connected) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, true, true, "You must be connected to a local TCP proxy to send a command to the RedBee RFID Reader."));
				return '';
			}
			
			sendCommand('rst\r');
			
			return sReturn;
			
		}
		
		// call or set xb
		public function xb (set:int=-1, cache:Boolean=false) : int
		{
			
			// set the return value to the default
			// as if we're request the value, not setting it
			// -1 indicates it hasn't been request before
			var nReturn:int = -1;
			
			// are set setting the value, or simply requesting it?
			if (set < 0) {
				
				// we're simply requesting it
				// are we using cache, and have we requested it before?
				if (cache == true && _xb > -1) {
					
					// return the cached value
					return _xb;
					
				} else {
					
					// request it from the device, and we'll return the result via an event
					// make sure we're still connected
					if (!connected) {
						dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, true, true, "You must be connected to a local TCP proxy to send a command to the RedBee RFID Reader."));
						return -1;
					}
					
					sendCommand('xb\r');
					
				}
				
			} else {
				
				// we're setting the value
				sendCommand('xb ' + set + '\r');
				
			}
			
			return -1;
			
		}
		
	}
}