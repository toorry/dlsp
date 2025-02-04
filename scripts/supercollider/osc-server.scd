OSCdef(\ctrlFromUI,
	{ arg msg;
		var channelType = msg[1],
		commandType, channelNumber, value, fb = false;

		if (~serverConf[\oscCtrlReady]) {

			switch (channelType,// CHANNEL TYPE
				\i,// INPUT
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\g,///GAIN
						{
							value = msg[4];
							~inputs[channelNumber-1][\synthGain].set(\gain, value);
							("input " ++ channelNumber ++ " gain " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\gain] = value;
						},
						\m,///MUTE
						{
							value = msg[4];
							//~inputs[channelNumber-1][\synthPan].set(\mute, value);
							("input " ++ channelNumber ++ " mute " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\mute] = value;
						},
						\v,///VOLUME AMPLITUDE
						{
							value = msg[4];
							~inputsMono[channelNumber-1][\synthInAmbSend].set(\volume, value);
							("input " ++ channelNumber ++ " volume " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\volume] = value;
						}
					);
				},
				\p,//POINT
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\g,///GAIN
						{
							~setPointGain.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\az,///AZIMUTH
						{
							~setPointAzim.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\el,///ELEVATION
						{
							~setPointElev.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\di,///DISTANCE
						{
							~setPointDist.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\pan,/// ALL PAN COORDS
						{
							~setPointPan.value(num: channelNumber - 1,
								x: msg[4], y: msg[5], z: msg[6], azim: msg[7], elev: msg[8], dist: msg[9], fb: false);
						},
						\m,///MUTE
						{
							~setPointMute.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\v,///VOLUME AMPLITUDE
						{
							~setPointVolume.value(num: channelNumber - 1, value: msg[4], fb: false);
						}
					);
				},
				\f,//FIELD
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\g,///GAIN
						{
							~setFieldGain.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\re,///REFLECT
						{
							//~setPointAzim.value(num: channelNumber - 1, value: msg[4]);
						},
						\ro,///ROTATE ANGLE
						{
							~setFieldRotate.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\ti,///TILT ANGLE
						{
							~setFieldTilt.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\tu,///TUMBLE ANGLE
						{
							~setFieldTumble.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\z, /// ZOOM ENABLE
						{
							~setFieldZoomActive.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\az,///ZOOM AZIMUTH
						{
							~setFieldZoomAzim.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\el,///ZOOM ELEVATION
						{
							~setFieldZoomElev.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\an,///ZOOM EFFECT ANGLE
						{
							~setFieldZoomAngle.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\di,///ZOOM EFFECT DISTANCE
						{
							~setFieldZoomDist.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\m,///MUTE
						{
							~setFieldMute.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\v,///VOLUME AMPLITUDE
						{
							~setFieldVolume.value(num: channelNumber - 1, value: msg[4], fb: false);
						}
					);
				},
				\o,// OUTPUT
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\d,/// DELAY
						{
							~setOutputDelay.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\m,///MUTE
						{
							~setOutputMute.value(num: channelNumber - 1, value: msg[4], fb: false);
						},
						\v,///VOLUME AMPLITUDE
						{
							~setOutputVolume.value(num: channelNumber - 1, value: msg[4], fb: false);
						}
					);
				}
			);
		};
	},
	'/ui');

OSCdef(\ctrlPoint,
	{ arg msg;
		var commandType, channelNumber, value;

		if (~serverConf[\oscCtrlReady]) {

			channelNumber = msg[2];
			commandType = msg[3];

			switch (commandType,///COMMAND TYPE
				\g,/// GAIN
				{
					~setPointGain.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\x,/// X
				{
					~setPointX.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\y,/// Y
				{
					~setPointY.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\z,/// Z
				{
					~setPointZ.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\azim,/// AZIMUTH
				{
					~setPointAzim.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\elev,/// ELEVATION
				{
					~setPointElev.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\dist,///DISTANCE
				{
					~setPointDist.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\pan,/// ALL PAN COORDS
				{
					~setPointPan.value(num: channelNumber - 1,
						x: msg[4], y: msg[5], z: msg[6], azim: msg[7], elev: msg[8], dist: msg[9], fb: true);
				},
				\m,/// MUTE
				{
					~setPointMute.value(num: channelNumber - 1, value: msg[4], fb: true);
				},
				\v,/// VOLUME DB
				{
					~setPointVolume.value(num: channelNumber - 1, value: msg[4].dbamp, fb: true);
				}
			);
		};
	},
	'/p');

OSCdef(\ctrlPatch,
	{ arg msg;
		var channelType = msg[1],
		commandType, channelNumber, value;

		if (~serverConf[\oscCtrlReady]) {

			switch (channelType,// CHANNEL TYPE
				/*\i,// INPUT
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\g,///GAIN
						{
							value = msg[4];
							~inputs[channelNumber-1][\synthGain].set(\gain, value);
							("input " ++ channelNumber ++ " gain " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\gain] = value;
						},
						\m,///MUTE
						{
							value = msg[4];
							//~inputs[channelNumber-1][\synthPan].set(\mute, value);
							("input " ++ channelNumber ++ " mute " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\mute] = value;
						},
						\v,///VOLUME
						{
							value = msg[4];
							~inputsMono[channelNumber-1][\synthInAmbSend].set(\volume, value);
							("input " ++ channelNumber ++ " volume " ++ value).postln;
							~stateCurrent[\inputs][channelNumber - 1][\volume] = value;
						}
					);
				},*/
				\p,//POINT
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\in,/// INPUT PATCH
						{
							~setPointPatchIn.value(num: channelNumber - 1, value: msg[4] -1);
						},
					);
				},
				\f,//FIELD
				{
					channelNumber = msg[2];
					commandType = msg[3];

					switch (commandType,///COMMAND TYPE
						\in,/// INPUT PATCH
						{
							~setFieldPatchIn.value(num: channelNumber - 1, value: msg[4] - 1);
						}
					);
				}
			);
		};
	},
	'/patch');

~decoderChangeMain = Routine {

	SynthDef(\decoderRoom, {
		arg busIn, busOut, busOutCtrl;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		//sig = FoaDecode.ar(sig, ~decoderRoom);
		sig = HoaDecodeMatrix.ar(sig, HoaMatrixDecoder.newModeMatch(
			~serverConf.[\mainDirections],
			beamShape: \basic,
			match: \amp,
			order: 1)
		);

		Out.ar( busOut, sig );
		//Out.kr( busOutCtrl, sigOut );
	}).add;
	s.sync();

	~synthDecoderRoom.free;
	s.sync();
	~synthDecoderRoom = Synth.new(\decoderRoom,
		[\busIn, ~buses[\ambMain],
			\busOut, [2,3,4,5,6,7,8,9,10,11],
		],
		~grpAmbMain,
		\addToTail);
};

OSCdef(\ctrlDecoder,
	{ arg msg;
		var commandType, decoderNumber, value;

		if (~serverConf[\oscCtrlReady]) {

			decoderNumber = msg[1];
			commandType = msg[2];

			switch (commandType,///COMMAND TYPE
				\dirs,///CHANNEL DIRECTIONS
				{
					("dec " ++ decoderNumber ++ " chan dirs").postln;
					value = [ msg[3], msg[4], msg[5], msg[6], msg[7], msg[8], msg[9], msg[10] ];
					~serverConf[\mainDirections] = value.degrad;
					~serverConf[\decoderMainSpeakersAmount] = 8;
					~stateCurrent[\decoderMain][\dirs] = ~serverConf[\mainDirections];
					~stateCurrent[\decoderMain][\speakersAmount] = ~serverConf[\decoderMainSpeakersAmount];

					~decoderChangeMain.value;
				}
			);
		};
	},
	'/de');

OSCdef(\ctrlServer,
	{ arg msg;
		var type = msg[1],
		commandType, channelNumber, value;

		if (~serverConf[\oscCtrlReady]) {

			switch (type,// CHANNEL TYPE
				\m,// MUTE
				{
					if (msg[2].asBoolean) {
						s.mute;
						("server muted").postln;
					} {
						s.unmute;
						("server unmuted").postln;
					}
				}
			);
		};
	},
	'/dlsp');

OSCdef(\stateSend,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");

		if (~serverConf[\oscCtrlReady]) {

			~sendState.value;
			~ostagec.sendMsg('/dlsp/log', time ++ " Sending State");
		};
	},
	'/dlsp/state/send');

OSCdef(\vuClear,
	{ arg msg;

		if (~serverConf[\oscCtrlReady]) {

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
			~vu[\hwOut][\firstChannel] = 0;
		};
	},
	'/vu/clear');

OSCdef(\vuSetIn,
	{ arg msg;
		var firstChannel = (msg[2] - 1).asInteger,
		channelsAmount = msg[1].asInteger;

		if (~serverConf[\oscCtrlReady]) {

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
		};
	},
	'/vu/in');

OSCdef(\volumeMeter,
	{ arg msg;
		var time = Date.getDate.format("%Y-%m-%d %H:%M:%S");

		if (~serverConf[\oscCtrlReady]) {

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
		};
	},
	'/v');