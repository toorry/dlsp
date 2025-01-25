//Initialise STATE

~initState = {

	"init states".postln;
	~stateCurrent.postln;

	~stateCurrentFile;
	~stateCurrent = Dictionary.new();
	~stateCurrent.put(\type, "dlspScene");
	~stateCurrent.put(\dlspSceneVersion, "0.1");

	~stateCurrent.put(\inputsMono, Array.newClear(~serverConf[\inputsMonoAmount]));
	~serverConf[\inputsMonoAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\number, num + 1);
		item.put(\name, ~inputsMono[num][\name]);
		item.put(\gain, ~inputsMono[num][\gain]);
		item.put(\azim, ~inputsMono[num][\azim]);
		item.put(\elev, ~inputsMono[num][\elev]);
		item.put(\dist, ~inputsMono[num][\dist]);
		item.put(\mute, ~inputsMono[num][\mute]);
		item.put(\volume, ~inputsMono[num][\volume]);
		~stateCurrent[\inputsMono][num] = item;

	});

	~stateCurrent.put(\decoderMain, Dictionary.new());
	~stateCurrent[\decoderMain].put(\number, 1);
	~stateCurrent[\decoderMain].put(\name, "Main");
	~stateCurrent[\decoderMain].put(\type, ~serverConf[\decoderMainType]);
	~stateCurrent[\decoderMain].put(\radius, ~serverConf[\roomRadius]);
	~stateCurrent[\decoderMain].put(\speakersAmount, ~serverConf[\decoderMainSpeakersAmount]);
	~stateCurrent[\decoderMain].put(\directions, ~serverConf[\mainDirections]);
	~stateCurrent[\decoderMain].put(\mute, 1);

	~loadState.value;
};

~saveCurrentState = Routine {
	loop {
		File.use(~path +/+ "states" +/+ "current.dlspstate", "w", { |f|
			f.write(JSONlib.convertToJSON(~stateCurrent));
		});
		~serverConf[\saveStateRate].wait;
	}
};

~sendState = {

	~serverConf[\inputsMonoAmount].do ({
		arg num;
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "gn", ~stateCurrent[\inputsMono][num][\gain]);
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "az", ~stateCurrent[\inputsMono][num][\azim]);
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "el", ~stateCurrent[\inputsMono][num][\elev]);
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "di", ~stateCurrent[\inputsMono][num][\dist]);
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "m", ~stateCurrent[\inputsMono][num][\mute]);
		~ostagec.sendMsg("/fb", "ch", "i", num + 1, "v", ~stateCurrent[\inputsMono][num][\volume]);
	});

	~ostagec.sendMsg("/fb", "de", 1, "name", ~stateCurrent[\decoderMain][\name]);
	~ostagec.sendMsg("/fb", "de", 1, "type", ~stateCurrent[\decoderMain][\type]);
	~ostagec.sendMsg("/fb", "de", 1, "r", ~stateCurrent[\decoderMain][\radius]);
	~ostagec.sendMsg("/fb", "de", 1, "spkn", ~stateCurrent[\decoderMain][\speakersAmount]);
	~ostagec.sendMsg("/fb", "de", 1, "dirs", ~stateCurrent[\decoderMain][\directions]);
	~sendBuffer = ["/fb", "de", 1, "dirs"] ++ ~stateCurrent[\decoderMain][\directions].raddeg;
	~ostagec.sendMsg(*~sendBuffer);
	~ostagec.sendMsg("/fb", "de", 1, "mute", ~stateCurrent[\decoderMain][\mute]);
};

~loadState = {

	if (File.exists(~path +/+ "states" +/+ "current.dlspstate")) {

		"dlsp state file exists".postln;
		~stateLoaded = nil;

		s.mute;

		try {
			~stateLoaded = JSONlib.parseFile(~path +/+ "states" +/+ "current.dlspstate");
			~stateLoaded.keys.do ({
				arg type;

				switch (type,
					\inputsMono, {//MONO INPUT CHANNEL

						~stateLoaded[type].size.do ({//EACH CHANNEL
							arg num;
							~stateLoaded[type][num].keys.do ({
								arg parameter;

								switch (parameter,
									\gain, {
										~stateCurrent[\inputsMono][num][\gain] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\gain] = ~stateCurrent[\inputsMono][num][\gain];
										~inputsMono[num][\synthInGain].set(\gain, ~inputsMono[num][\gain]);
										("loaded from state file in " ++ (num + 1) ++ " gain " ++
											~stateLoaded[type][num][parameter]).postln;
									},
									\azim, {
										~stateCurrent[\inputsMono][num][\azim] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\azim] = ~stateCurrent[\inputsMono][num][\azim];
										~inputsMono[num][\synthInAmbPan].set(\azimuth, ~inputsMono[num][\azim]);
										("loaded from state file in " ++ (num + 1) ++ " azim " ++
											~stateLoaded[type][num][parameter]).postln;
									},
									\elev, {
										~stateCurrent[\inputsMono][num][\elev] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\elev] = ~stateCurrent[\inputsMono][num][\elev];
										~inputsMono[num][\synthInAmbPan].set(\elevation, ~inputsMono[num][\elev]);
										("loaded from state file in " ++ (num + 1) ++ " elev " ++
											~stateLoaded[type][num][parameter]).postln;
									},
									\dist, {
										~stateCurrent[\inputsMono][num][\dist] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\dist] = ~stateCurrent[\inputsMono][num][\dist];
										~inputsMono[num][\synthInAmbPan].set(
											\radius, ~inputsMono[num][\dist].clip(0.1,1000),
											\distance, ~inputsMono[num][\dist].clip(~serverConf[\roomRadius],1000));
										("loaded from state file in " ++ (num + 1) ++ " dist " ++
											~stateLoaded[type][num][parameter]).postln;
									},
									\mute, {
										~stateCurrent[\inputsMono][num][\mute] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\mute] = ~stateCurrent[\inputsMono][num][\mute];
										~inputsMono[num][\synthInAmbPan].set(\mute, ~inputsMono[num][\mute]);
										("loaded from state file in " ++ (num + 1) ++ " mute " ++
											~stateLoaded[type][num][parameter]).postln;
									},
									\volume, {
										~stateCurrent[\inputsMono][num][\volume] = ~stateLoaded[type][num][parameter];
										~inputsMono[num][\volume] = ~stateCurrent[\inputsMono][num][\volume];
										~inputsMono[num][\synthInAmbSend].set(\volume, ~inputsMono[num][\volume]);
										("loaded from state file in " ++ (num + 1) ++ " volume " ++
											~stateLoaded[type][num][parameter]).postln;
									},
								);
							});
						});
					},
				);
			});
			~stateCurrent[\decoderMain][\speakersAmount] = ~stateLoaded[\decoderMain][\speakersAmount];
			~stateCurrent[\decoderMain][\directions] = ~stateLoaded[\decoderMain][\directions];
			~serverConf[\mainDirections] = ~stateCurrent[\decoderMain][\directions];
			~serverConf[\decoderMainSpeakersAmount] = ~stateCurrent[\decoderMain][\speakersAmount];
		} { |error|
			//
		};

		s.unmute;

	} {}
};