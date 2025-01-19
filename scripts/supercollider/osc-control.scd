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
						channelNumber = msg[3].postln;
						value = msg[4].postln;
						~inputsMono[channelNumber-1][\synthInAmbSend].set(\volume, value).postln;
					},
				);
			},
		);
	},
	'/ch');