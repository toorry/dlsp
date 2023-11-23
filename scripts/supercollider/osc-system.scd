OSCdef(\ping,
	{ arg msg;
		~ostagec.sendMsg('/dlsp/sclang/status', 1);
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' System status OK');
	},
	'/dlsp/ping');

OSCdef(\translatePort,
	{ arg msg;
		' Request for port number received. Transmitting..'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Request for port number received. Transmitting..');
		for(1024, 65535) {
			arg i;
			~ostagec.port = i;
			~ostagec.sendMsg('/dlsp/log', "sclang port" + ~myoscaddr.port.asString);

		};
		~ostagec.port = ~dlspSettingsDict['web-ui-port'].asInteger;
	},
	'/dlsp/find');

OSCdef(\startServer,
	{ arg msg;
		'ostagec msg to boot server'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Booting sound server..');
		~vuSend.reset;
		~regularBoot.next;
	},
	'/dlsp/server/start');

OSCdef(\stopServer,
	{ arg msg;
		'ostagec msg to quit server'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Quitting sound server..');
		~vuSend.stop;
		//~vuSend.reset;
		~regularBoot.reset;
		s.quit;
	},
	'/dlsp/server/stop');

OSCdef(\reboot,
	{ arg msg;
		'ostagec msg to reboot system'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Rebooting..');
		"systemctl reboot -i".unixCmd; },
	'/dlsp/reboot');

OSCdef(\shutdown,
	{ arg msg;
		'ostagec msg to shutdown system'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Shutting down..');
		"systemctl poweroff -i".unixCmd; },
	'/dlsp/shutdown');

//~regularBoot.reset;