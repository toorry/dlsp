OSCdef(\ping,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		~ostagec.sendMsg('/dlsp/sclang/status', 1);
		~ostagec.sendMsg('/dlsp/log', time ++ " System status OK");
	},
	'/dlsp/ping');

OSCdef(\translatePort,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		time ++ " Request for port number received. Transmitting..".postln;
		~ostagec.sendMsg('/dlsp/log', time ++ " Request for port number received. Transmitting..");
		for(1024, 65535) {
			arg i;
			~ostagec.port = i;
			~ostagec.sendMsg('/dlsp/log', "sclang port " ++ ~myoscaddr.port.asString);

		};
		~ostagec.port = ~dlspSettingsDict['web-ui-port'].asInteger;
	},
	'/dlsp/find');

OSCdef(\startServer,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		time ++ " ostagec msg to boot server".postln;
		~ostagec.sendMsg('/dlsp/log', time + " Booting sound server..");
		~vmSend.reset;
		~saveCurrentState.reset;
		~regularBoot.next;
	},
	'/dlsp/server/start');

OSCdef(\stopServer,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		time ++ " ostagec msg to quit server".postln;
		~ostagec.sendMsg('/dlsp/log', time + " Quitting sound server..");
		~vmSend.stop;
		~saveCurrentState.stop;
		//~vuSend.reset;
		~regularBoot.reset;
		~decoderBin.free;
		~decoderRoom.free;
		~encoderBin.free;
		s.quit;
	},
	'/dlsp/server/stop');

OSCdef(\reboot,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		time ++ " ostagec msg to reboot system".postln;
		~ostagec.sendMsg('/dlsp/log', time + " Rebooting..");
		//"systemctl reboot -i".unixCmd; //FOR LINUX
		"shutdown /r".unixCmd; //FOR WIN
	},
	'/dlsp/reboot');

OSCdef(\shutdown,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		time ++ " ostagec msg to shutdown system".postln;
		~ostagec.sendMsg('/dlsp/log', time + " Shutting down..");
		//"systemctl poweroff -i".unixCmd; //FOR LINUX
		"shutdown /s".unixCmd; //FOR WIN
		0.exit;
	},
	'/dlsp/shutdown');

/*OSCdef(\stateSave,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		~saveCurrentState.value;
		~ostagec.sendMsg('/dlsp/log', time ++ "    Saving Current State");
	},
	'/dlsp/state/save');*/

OSCdef(\stateSend,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		~sendState.value;
		~ostagec.sendMsg('/dlsp/log', time ++ " Sending State");
	},
	'/dlsp/state/send');

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

OSCdef(\volumeMeter,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");
		msg.postln;
		msg[0].postln;
		msg[1].postln;
		msg[2].postln;
		msg[3].postln;
		msg[4].postln;
		switch (msg[1],
			\clear, {
				//~vm.keys.do ({
				//	arg chanType;
				//	~vm[chanType].keys.do ({
				//		arg busType;
				//		~vm[chanType][busType].clear;
				//	});
				//});
			},
			\rate, {
				if (
					msg[2] != nil,
					{
						try {
							~vmRate = msg[2].asFloat;
						} { |error|
							~ostagec.sendMsg('/dlsp/log',
								time ++ "\n" + error.dump);
						};
						~ostagec.sendMsg('/dlsp/log',
							time ++ " Volume Metering Rate changed to " + ~vmRate);
					}, {}
				);
			},
			\packMaxSize, {
				if (
					msg[2] != nil,
					{
						try {
							~vmRate = msg[2].asInteger;
						} { |error|
							~ostagec.sendMsg('/dlsp/log',
								time ++ "\n" + error.dump);
						};
						~ostagec.sendMsg('/dlsp/log',
							time ++ " Max Package Size changed to " + ~vmPackMaxSize);
					}, {}
				);
			},
			\all, {
				//
			},
			\none, {
				//
			},
			\start, {
				var channelType, busType;
				var allBuses = false;
				var uniqueBus = true;
				var busesAmount = 0;
				var wrongMsg = false;
				"'start' case".postln;

				(
					"searching channel type".postln;
					switch (msg[2],
						\s, {//SOURCE CHANNEL
							channelType = \sources;
						},
						\i, {//INPUT CHANNEL
							channelType = \inputs;
							if (msg[3] > ~inputsAmount) { wrongMsg = true; } {}
						},
						\m, {//MIX CHANNEL
							channelType = \mixes;
							if (msg[3] > ~mixesAmount) { wrongMsg = true; } {}
						},
						\p, {//POINT CHANNEL
							channelType = \points;
							if (msg[3] > ~pointsAmount) { wrongMsg = true; } {}
						},
						\f, {//FIELD FLOW
							channelType = \fields;
							if (msg[3] > ~fieldsAmount) { wrongMsg = true; } {}
						},
						\s, {//SPACE FLOW
							channelType = \spaces;
							if (msg[3] > ~spacesAmount) { wrongMsg = true; } {}
						},
						\o, {//OUTPUT CHANNEL
							channelType = \outputs;
							if (msg[3] > ~outputsAmount) { wrongMsg = true; } {}
						},
						nil, {
							wrongMsg = true;
						}
					);
					"channel found".postln;
				);
				if ( msg[3] == nil, {
					wrongMsg = true;
				}, {}
				);
				(
					switch (msg[4],
						\in, {//INPUT BUS
							busType = \in;
						},
						\gn, {//GAIN BUS
							busType = \gain;
						},
						\gt, {//GATE BUS
							busType = \gate;
						},
						\eq, {//EQ BUS
							busType = \eq;
						},
						\dq, {//DYN EQ BUS
							busType = \dynEQ;
						},
						\cp, {//COMP BUS
							busType = \comp;
						},
						\is, {//INSERT BUS
							busType = \ins;
						},
						\lt, {//LIMIT BUS
							busType = \limit;
						},
						\ms, {//ALL MIX SENDS
							busType = \mixSend;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~mixesAmount;
						},
						\md, {//MIX SEND BUS
							busType = \mixSend;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~mixesAmount , { wrongMsg = true; } );
						},
						\ps, {//ALL POINT SENDS
							busType = \pointSend;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~pointsAmount;
						},
						\pd, {//POINT SEND BUS
							busType = \pointSend;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~pointsAmount , { wrongMsg = true; } );
						},
						\os, {//ALL OUTPUT SENDS
							busType = \outSend;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~outputsAmount;
						},
						\od, {//OUTPUT SEND BUS
							busType = \outSend;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~outputsAmount , { wrongMsg = true; } );
						},
						\fs, {//ALL FIELD PAN BUSES
							busType = \fieldPan;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~fieldsAmount;
						},
						\fd, {//FIELD PAN BUS
							busType = \fieldPan;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~fieldsAmount , { wrongMsg = true; } );
						},
						\ss, {//ALL SPACE PAN BUSES
							busType = \spacePan;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~spacesAmount;
						},
						\sc, {//SPACE PAN BUS
							busType = \spacePan;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~spacesAmount , { wrongMsg = true; } );
						},
						\ls, {//ALL AMB TRANSFORM BUSES
							busType = \slot;
							uniqueBus = false;
							allBuses = true;
							busesAmount = ~ambTransformerSlots;
						},
						\lt, {//AMB TRANSFORM BUS
							busType = \slot;
							uniqueBus = false;
							if ( msg[5] == nil , { wrongMsg = true; } );
							if ( msg[5] > ~ambTransformerSlots , { wrongMsg = true; } );
						},
						\nf, {//NEAR FIELD CONTROL BUS
							busType = \nfc;
						},
						\op, {//PRE FADER BUS
							busType = \outPre;
						},
						\ot, {//POST FADER BUS
							busType = \out;
						},
						nil, {
							wrongMsg = true;
						}
					);
					"bus found".postln;
				);
				if (wrongMsg == false) {
					case
					{ allBuses } {
						busesAmount.do ({
							arg num;
							~vm[channelType][busType].add( [ msg[3], num ] );
						});
					}
					{ uniqueBus } {
						~vm[channelType][busType].add( msg[3] );
					}
					{ true } {
						~vm[channelType][busType].add( [ msg[3], msg[5] ] );
					};
				} {};
				(channelType ++ busType ++ msg[3]).postln;
			},
			\stop, {
				//
			},
		);
	},
	'/v');