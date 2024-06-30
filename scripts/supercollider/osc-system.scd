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
		~vmSend.reset;
		~regularBoot.next;
	},
	'/dlsp/server/start');

OSCdef(\stopServer,
	{ arg msg;
		'ostagec msg to quit server'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Quitting sound server..');
		~vmSend.stop;
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

OSCdef(\vuClear,
	{ arg msg;
		~vu[\hwIn][\channelsAmount] = 0;
		~vu[\hwIn][\firstChannel] = 0;
		~vu[\inputs][\channelsAmount] = 0;
		~vu[\inputs][\firstChannel] = 0;
		~vu[\mixes][\channelsAmount] = 0;
		~vu[\mixes][\firstChannel] = 0;
		~vu[\points][\channelsAmount] = 0;
		~vu[\points][\firstChannel] = 0;
		~vu[\fields][\channelsAmount] = 0;
		~vu[\fields][\firstChannel] = 0;
		~vu[\spaces][\channelsAmount] = 0;
		~vu[\spaces][\firstChannel] = 0;
		~vu[\decoders][\channelsAmount] = 0;
		~vu[\decoders][\firstChannel] = 0;
		~vu[\outputs][\channelsAmount] = 0;
		~vu[\outputs][\firstChannel] = 0;
		~vu[\hwOut][\channelsAmount] = 0;
		~vu[\hwOut][\firstChannel] = 0; },
	'/vu/clear');

OSCdef(\vuSetIn,
	{ arg msg;
		var firstChannel = (msg[2] - 1).asInteger,
		channelsAmount = msg[1].asInteger;
		msg.postln;
		channelsAmount.postln;
		firstChannel.postln;
		if(firstChannel == ~inputsAmount) {
			firstChannel = 0;
			channelsAmount = 0;
		} {
			if(firstChannel < 0) {
				channelsAmount = channelsAmount + firstChannel;
				firstChannel = 0;
			};
			if((firstChannel + channelsAmount - 1) >= 4) {
				channelsAmount = ~inputsAmount - firstChannel;
			};
		};
		~vu[\inputs][\firstChannel] = firstChannel;
		~vu[\inputs][\channelsAmount] = channelsAmount;
	},
	'/vu/in');