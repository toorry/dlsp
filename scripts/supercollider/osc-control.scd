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
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\azimuth, value);
						("point " ++ channelNumber ++ " azimuth " ++ value).postln;
					},
					\el,///ELEVATION ANGLE
					{
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\elevation, value);
						("point " ++ channelNumber ++ " elevation " ++ value).postln;
					},
					\di,///DISTANCE
					{
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(
							\approach, 1-value.clip(0,1), \distance, value.clip(1,4));
						("point " ++ channelNumber ++ " distance " ++ value.clip(1,4) ++
							" approach " ++ (1-value.clip(0,1))).postln;
					}
				);
			}
		);
	},
	'/ch');