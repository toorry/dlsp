//Initialise STATE

~initState = {

	"init states".postln;
	~stateCurrent.postln;

	~stateCurrentFile;
	~stateCurrent = Dictionary.new();
	~stateCurrent.put(\type, "dlspScene");
	~stateCurrent.put(\dlspSceneVersion, "0.1");

	~stateCurrent.put(\points, Array.newClear(~serverConf[\pointsAmount]));
	~serverConf[\pointsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\number, num + 1);
		item.put(\name, ~points[num][\name]);
		item.put(\patchIn, 0);
		item.put(\gain, ~points[num][\gain]);
		item.put(\azim, ~points[num][\azim]);
		item.put(\elev, ~points[num][\elev]);
		item.put(\dist, ~points[num][\dist]);
		item.put(\mute, ~points[num][\mute]);
		item.put(\volume, ~points[num][\volume]);
		~stateCurrent[\points][num] = item;

	});

	~stateCurrent.put(\fields, Array.newClear(~serverConf[\fieldsAmount]));
	~serverConf[\fieldsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\number, num + 1);
		item.put(\name, ~fields[num][\name]);
		item.put(\patchIn, 0);
		item.put(\gain, ~fields[num][\gain]);
		item.put(\reflect, ~fields[num][\reflect]);
		item.put(\rotate, ~fields[num][\rotate]);
		item.put(\tilt, ~fields[num][\tilt]);
		item.put(\tumble, ~fields[num][\tumble]);
		item.put(\zoom, Dictionary.new());
		item[\zoom].put(\azim, ~fields[num][\zoom][\azim]);
		item[\zoom].put(\elev, ~fields[num][\zoom][\elev]);
		item[\zoom].put(\dist, ~fields[num][\zoom][\dist]);
		item[\zoom].put(\angle, ~fields[num][\zoom][\angle]);
		item.put(\mute, ~fields[num][\mute]);
		item.put(\volume, ~fields[num][\volume]);
		~stateCurrent[\fields][num] = item;

	});

	~stateCurrent.put(\outputs, Array.newClear(~serverConf[\outputsAmount]));
	~serverConf[\outputsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\number, num + 1);
		item.put(\name, ~outputs[num][\name]);
		item.put(\patchOut, 0);
		item.put(\delay, ~outputs[num][\delay]);
		item.put(\mute, ~outputs[num][\mute]);
		item.put(\volume, ~outputs[num][\volume]);
		~stateCurrent[\outputs][num] = item;

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

	~serverConf[\pointsAmount].do ({
		arg num;
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "gn", ~stateCurrent[\points][num][\gain]);
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "az", ~stateCurrent[\points][num][\azim]);
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "el", ~stateCurrent[\points][num][\elev]);
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "di", ~stateCurrent[\points][num][\dist]);
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "m", ~stateCurrent[\points][num][\mute]);
		~ostagec.sendMsg("/fb", "ch", "p", num + 1, "v", ~stateCurrent[\points][num][\volume]);
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
					\points, {//MONO INPUT CHANNEL

						~stateLoaded[type].size.do ({//EACH CHANNEL
							arg num;
							~stateLoaded[type][num].keys.do ({
								arg parameter;

								switch (parameter,
									\gain, {
										~setPointGain.value(num: num, value: ~stateLoaded[type][num][parameter]);
										"loaded from state file".postln;
									},
									\azim, {
										~setPointAzim.value(num: num, value: ~stateLoaded[type][num][parameter]);
										"loaded from state file point".postln;
									},
									\elev, {
										~setPointElev.value(num: num, value: ~stateLoaded[type][num][parameter]);
										"loaded from state file point".postln;
									},
									\dist, {
										~setPointDist.value(num: num, value: ~stateLoaded[type][num][parameter]);
										"loaded from state file point".postln;
									},
									\mute, {
										~stateCurrent[\points][num][\mute] = ~stateLoaded[type][num][parameter];
										~points[num][\mute] = ~stateCurrent[\points][num][\mute];
										~points[num][\synthPan].set(\mute, ~points[num][\mute]);
										"loaded from state file point".postln;
									},
									\volume, {
										~setPointVolume.value(num: num, value: ~stateLoaded[type][num][parameter]);
										"loaded from state file point".postln;
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