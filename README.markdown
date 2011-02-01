## RedBee RFID Reader ActionScript Library

> Version 0.3

## Contributors

* Scott Mebberson <scott@scottmebberson.com>, [http://scottmebberson.com](http://scottmebberson.com) Current Developer

## About

This is an ActionScript 3 library allowing you directly interact with the RedBee RFID reader from within ActionScript (Flex, AIR and Flash).
Most of the documentation, in fact all, that comes with RedBee is PC and .NET oriented. I wanted to provide something that is MAC and ActionScript oriented. Arduino and Phidgets have good support for those platforms, and hopefully RedBee will be closer to that soon.

At the moment, I'm just finalising the communication without Xbee bpan networking mode enabled, however, I plan to support this too shortly.

## Features

*	recieve an asynchronous tag swipe event (theoretically supports other asynchronous events, but are untested as yet)
*   recieve synchronous events (after issuing commands to the device)
	*	retrieve the firmware version (fw) of the RedBee (with support for returning cached values)
	*   issue the rst command, and if boot prompt mode is enabled, return the result (with support for returning cached values)
	*   set, and retrieve the Xbee bpan networking mode (xb) of the RedBee (with support for returning cached values)
	*	save the most recent tag that was swiped