package com.scottmebberson.redbee
{
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class RFIDReader extends Socket
	{
		
		private static const EOL_DELIMITER : String = "\r\n>";
		
		public function RFIDReader(host:String='127.0.0.1', port:int=5331)
		{
			
			super(host, port);
			
		}
		
	}
}