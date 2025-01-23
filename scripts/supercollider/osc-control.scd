OSCdef(\ctrlChannel,
	{ arg msg;
		var channelType = msg[1],
		commandType, channelNumber, value;

		switch (channelType,// CHANNEL TYPE
			\i,// INPUT
			{
				channelNumber = msg[2];
				commandType = msg[3];

				switch (commandType,///COMMAND TYPE
					\g,///GAIN
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInGain].set(\gain, value);
						("input " ++ channelNumber ++ " gain " ++ value).postln;
					},
					\m,///MUTE
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\mute, value);
						("input " ++ channelNumber ++ " mute " ++ value).postln;
					},
					\v,///VOLUME
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbSend].set(\volume, value);
						("input " ++ channelNumber ++ " volume " ++ value).postln;
					}
				);
			},
			\p,//POINT
			{
				channelNumber = msg[2];
				commandType = msg[3];

				switch (commandType,///COMMAND TYPE
					\az,///AZIMUTH ANGLE
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\azimuth, value);
						("point " ++ channelNumber ++ " azimuth " ++ value).postln;
					},
					\el,///ELEVATION ANGLE
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\elevation, value);
						("point " ++ channelNumber ++ " elevation " ++ value).postln;
					},
					\di,///DISTANCE
					{
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbPan].set(
							\radius, value.clip(0.1,1),
							\distance, value.clip(1,1000));
						("point " ++ channelNumber ++ " distance " ++ value).postln;
					}
				);
			}
		);
	},
	'/ch');

OSCdef(\ctrlDecoder,
	{ arg msg;
		var commandType, decoderNumber, value;

		decoderNumber = msg[1];
		commandType = msg[2];

		switch (commandType,///COMMAND TYPE
			\dirs,///CHANNEL DIRECTIONS
			{
				("dec " ++ decoderNumber ++ " chan dirs").postln;
				value = [ msg[3], msg[4], msg[5], msg[6], msg[7], msg[8], msg[9], msg[10] ];
				~serverConf[\mainDirections] = value.degrad;
				//~decoderRoom.dirChannels = value.degrad;
			}
		);
	},
	'/de');