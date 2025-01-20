OSCdef(\ctrlChannel,
	{ arg msg;
		var channelType = msg[1],
		commandType, channelNumber, value;

		switch (channelType,// CHANNEL TYPE
			\i,// INPUT
			{
				commandType = msg[2];

				switch (commandType,///COMMAND TYPE
					\v,///VOLUME
					{
						channelNumber = msg[3];
						value = msg[4];
						~inputsMono[channelNumber-1][\synthInAmbSend].set(\volume, value);
						("input " ++ msg[3] ++ " volume " ++ value).postln;
					}
				);
			},
			\p,//POINT
			{
				commandType = msg[2];

				switch (commandType,///COMMAND TYPE
					\az,///AZIMUTH ANGLE
					{
						channelNumber = msg[3].postln;
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\azimuth, value);
						("point " ++ msg[3] ++ " azimuth " ++ value).postln;
					},
					\el,///ELEVATION ANGLE
					{
						channelNumber = msg[3].postln;
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(\elevation, value);
						("point " ++ msg[3] ++ " elevation " ++ value).postln;
					},
					\di,///DISTANCE
					{
						channelNumber = msg[3].postln;
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbPan].set(
							\approach, 1-value.clip(0,1), \distance, value.clip(1,4));
						("point " ++ msg[3] ++ " distance " ++ value.clip(1,4) ++
							" approach " ++ (1-value.clip(0,1))).postln;
					}
				);
			}
		);
	},
	'/ch');