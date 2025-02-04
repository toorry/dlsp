~initBuses = {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~hwIn = ~serverConf[\inPatch];
	~hwOut = ~serverConf[\outPatch];

	~busSilent = Bus.audio(s,1);
	~busSilentCtrl = Bus.control(s, 1);
	~busSilentAmb = Bus.audio(s, ~serverConf[\ambChansAmount]);
	~busTrash = Bus.audio(s,1);
	~busTrashCtrl = Bus.control(s, 1);
	~busTrashAmb = Bus.audio(s, ~serverConf[\ambChansAmount]);

	~buses = Dictionary();
	~buses.put(\points,Array.newClear(~serverConf[\pointsAmount]));
	~buses.put(\fields,Array.newClear(~serverConf[\fieldsAmount]));
	~buses.put(\ambMain, Bus.audio(s, ~serverConf[\ambChansAmount]));
	~buses.put(\ambMainCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
	~buses.put(\outputs,Array.newClear(~serverConf[\outputsAmount]));

	~serverConf[\pointsAmount].do ({
		arg num;
		var item = Dictionary.new();
		if ( num < ~hwIn.size ) { item.put(\in, ~hwIn[num]); } { item.put(\in, ~busSilent); };
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\gain,Bus.audio(s,1));
		item.put(\gainCtrl, Bus.control(s, 1));
		item.put(\out, Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\outCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		~buses[\points][num]=item;
	});
	~buses[\points].postln;

	~serverConf[\fieldsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\in, ~busSilentAmb);
		item.put(\inCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\gain,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\gainCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\reflect,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\reflectCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\transform,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\transformCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\zoom,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\zoomCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\out,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\outCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		~buses[\fields][num]=item;
	});
	~buses[\fields].postln;

	~buses.put(\outputsIn, Bus.audio(s, ~serverConf[\outputsAmount]));
	~buses.put(\outputsInCtrl, Bus.control(s, ~serverConf[\outputsAmount]));

	~serverConf[\outputsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\in, Bus.newFrom(~buses[\outputsIn], num, 1));
		item.put(\inCtrl, Bus.newFrom(~buses[\outputsInCtrl], num, 1));
		item.put(\delay, Bus.audio(s, 1));
		if ( num < ~hwOut.size ) { item.put(\out, ~hwOut[num]); } { item.put(\out, ~busTrash); };
		item.put(\outCtrl, Bus.control(s, 1));
		~buses[\outputs][num]=item;
	});
	~buses[\outputs].postln;

};

~initChannels = {

	//Initialise POINTS
	~points = Array.newClear(~serverConf[\pointsAmount]);

	~serverConf[\pointsAmount].do({
		arg num;
		var item = Dictionary.new();
		item.put(\name, "Point " ++ (num + 1));
		item.put(\patchIn, 0);
		item.put(\gain, ~defaultValues[\point][\gain]);
		item.put(\X, ~defaultValues[\point][\X]);
		item.put(\Y, ~defaultValues[\point][\Y]);
		item.put(\Z, ~defaultValues[\point][\Z]);
		item.put(\azim, ~defaultValues[\point][\azim]);
		item.put(\elev, ~defaultValues[\point][\elev]);
		item.put(\dist, ~serverConf[\roomRadius]);
		item.put(\mute, ~defaultValues[\point][\mute]);
		item.put(\volume, ~defaultValues[\point][\volume]);
		item.put(\busIn, ~buses[\points][num][\in]);
		item.put(\busInCtrl, ~buses[\points][num][\inCtrl]);
		item.put(\busGain, ~buses[\points][num][\gain]);
		item.put(\busGainCtrl, ~buses[\points][num][\gainCtrl]);
		item.put(\busOut, ~buses[\points][num][\out]);
		item.put(\busOutCtrl, ~buses[\points][num][\outCtrl]);
		~points[num] = item;
	});
	~points.postln;

	//Initialize FIELDS
	~fields = Array.newClear(~serverConf[\fieldsAmount]);

	~serverConf[\fieldsAmount].do({
		arg num;
		var item = Dictionary.new();
		item.put(\name, "Field " ++ (num + 1));
		item.put(\patchIn, 0);
		item.put(\gain, ~defaultValues[\field][\gain]);
		item.put(\reflect, ~defaultValues[\field][\reflect]);
		item.put(\rotate, ~defaultValues[\field][\rotate]);
		item.put(\tilt, ~defaultValues[\field][\tilt]);
		item.put(\tumble, ~defaultValues[\field][\tumble]);
		item.put(\zoom, Dictionary.new());
		item[\zoom].put(\azim, ~defaultValues[\field][\zoom][\azim]);
		item[\zoom].put(\elev, ~defaultValues[\field][\zoom][\elev]);
		item[\zoom].put(\dist, ~defaultValues[\field][\zoom][\dist]);
		item[\zoom].put(\angle, ~defaultValues[\field][\zoom][\angle]);
		item.put(\mute, ~defaultValues[\field][\mute]);
		item.put(\volume, ~defaultValues[\field][\volume]);
		item.put(\busIn, ~buses[\fields][num][\in]);
		item.put(\busInCtrl, ~buses[\fields][num][\inCtrl]);
		item.put(\busGain, ~buses[\fields][num][\gain]);
		item.put(\busGainCtrl, ~buses[\fields][num][\gainCtrl]);
		item.put(\busReflect, ~buses[\fields][num][\reflect]);
		item.put(\busReflectCtrl, ~buses[\fields][num][\reflectCtrl]);
		item.put(\busTransform, ~buses[\fields][num][\transform]);
		item.put(\busTransformCtrl, ~buses[\fields][num][\transformCtrl]);
		item.put(\busZoom, ~buses[\fields][num][\zoom]);
		item.put(\busZoomCtrl, ~buses[\fields][num][\zoomCtrl]);
		item.put(\busOut, ~buses[\fields][num][\out]);
		item.put(\busOutCtrl, ~buses[\fields][num][\outCtrl]);
		~fields[num] = item;
	});
	~fields.postln;

	// Initialize OUTPUTS
	~outputs = Array.newClear(~serverConf[\outputsAmount]);

	~serverConf[\outputsAmount].do({
		arg num;
		var item = Dictionary.new();
		item.put(\name, "Out " ++ (num + 1));
		item.put(\delay, ~defaultValues[\output][\delay]);
		item.put(\mute, ~defaultValues[\output][\mute]);
		item.put(\volume, ~defaultValues[\output][\volume]);
		item.put(\busIn, ~buses[\outputs][num][\in]);
		item.put(\busInCtrl, ~buses[\outputs][num][\inCtrl]);
		item.put(\busDelay, ~buses[\outputs][num][\delay]);
		item.put(\busOut, ~buses[\outputs][num][\out]);
		item.put(\busOutCtrl, ~buses[\outputs][num][\outCtrl]);
		~outputs[num] = item;
	});
	~outputs.postln;
};

//Initialize GROUPS

~initGroups = {

	~grpPoints = Group.new(s);
	~grpFields = Group.after(~grpPoints);
	~grpAmbMain = Group.after(~grpFields);
	~grpOutputs = Group.after(~grpAmbMain);

	~grpPoint = Array.newClear(~serverConf[\pointsAmount]);
	~grpField = Array.newClear(~serverConf[\fieldsAmount]);
	~grpOutput = Array.newClear(~serverConf[\outputsAmount]);

	~serverConf[\pointsAmount].do({
		arg num;
		~grpPoint[num] = Group.tail(~grpPoints);
	});

	~serverConf[\fieldsAmount].do({
		arg num;
		~grpField[num] = Group.tail(~grpFields);
	});

	~serverConf[\outputsAmount].do({
		arg num;
		~grpOutput[num] = Group.tail(~grpOutputs);
	});
};

//~grpInputMono[1].postln;

//Initialise SYNTHS

~initSynths = {

	~serverConf[\pointsAmount].do({
		arg num;
		var item = ~points[num];

		item.put(\synthGain, Synth.new(\inGain,
			[\busIn, item[\busIn],
				\busInCtrl, item[\busInCtrl],
				\busOut, item[\busGain],
				\busOutCtrl, item[\busGainCtrl],
				\gain, ~defaultValues[\point][\gain]
			],
			~grpPoint[num],
			\addToTail)
		);
		item.put(\synthPan, Synth.new(\ambPan,
			[\busIn, item[\busGain],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl],
				\dist, ~defaultValues[\point][\dist],
				\r, ~defaultValues[\point][\dist].clip(0.1, 1000)
			],
			~grpPoint[num],
			\addToTail)
		);
		item.put(\synthSend, Synth.new(\ambSend,
			[\busIn, item[\busOut],
				\busOut, ~buses[\ambMain],
				\volume, 1
			],
			~grpPoint[num],
			\addToTail)
		);
	});

	~serverConf[\fieldsAmount].do({
		arg num;
		var item = ~fields[num];

		item.put(\synthGain, Synth.new(\ambGain,
			[\busIn, item[\busIn],
				\busOut, item[\busGain],
				\busOutCtrl, item[\busGainCtrl],
				\gain, ~defaultValues[\field][\gain]
			],
			~grpField[num],
			\addToTail)
		);
		item.put(\synthTransform, Synth.new(\ambTransform,
			[\busIn, item[\busGain],
				\busOut, item[\busTransform],
				\busOutCtrl, item[\busTransformCtrl],
				\rotate, ~defaultValues[\field][\rotate],
				\tilt, ~defaultValues[\field][\tilt],
				\tumble, ~defaultValues[\field][\tumble]
			],
			~grpField[num],
			\addToTail)
		);
		item.put(\synthZoom, Synth.new(\ambZoom,
			[\busIn, item[\busTransform],
				\busOut, item[\busZoom],
				\busOutCtrl, item[\busZoomCtrl],
				\azim, ~defaultValues[\field][\zoom][\azim],
				\elev, ~defaultValues[\field][\zoom][\elev],
				\dist, ~defaultValues[\field][\zoom][\dist],
				\angle, ~defaultValues[\field][\zoom][\angle]
			],
			~grpField[num],
			\addToTail)
		);
		item.put(\synthSend, Synth.new(\ambSend,
			[\busIn, item[\busZoom],
				\busOut, ~buses[\ambMain],
				\mute, ~defaultValues[\field][\mute],
				\volume, ~defaultValues[\field][\volume]
			],
			~grpField[num],
			\addToTail)
		);
	});

	~synthDecoderBin = Synth.new(\decoderBin,
		[\busIn, ~buses[\ambMain],
			\busOut,
			[
				~outputs[0][\busIn],
				~outputs[1][\busIn]
			],
		],
		~grpAmbMain,
		\addToTail);

	~synthDecoderRoom = Synth.new(\decoderRoom,
		[\busIn, ~buses[\ambMain],
			\busOut,
			[
				~outputs[2][\busIn],
				~outputs[3][\busIn],
				~outputs[4][\busIn],
				~outputs[5][\busIn],
				~outputs[6][\busIn],
				~outputs[7][\busIn],
				~outputs[8][\busIn],
				~outputs[9][\busIn],
			],
		],
		~grpAmbMain,
		\addToTail);

	~serverConf[\outputsAmount].do({
		arg num;
		var item = ~outputs[num];
		item.put(\synthDelay, Synth.new(\monoDelay,
			[\busIn, item[\busIn],
				\busOut, item[\busDelay],
				\delay, 0.0
			],
			~grpOutput[num],
			\addToTail)
		);
		item.put(\synthSend, Synth.new(\monoSend,
			[\busIn, item[\busDelay],
				\busOut, item[\busOut],
				\mute, 1.0,
				\volume, 1.0
			],
			~grpOutput[num],
			\addToTail)
		);
	});

};



~regularBoot = Routine {

	s.options.device = ~serverConf[\defaultDevice];
	s.options.numInputBusChannels = ~serverConf[\hardwareInputsAmount];
	s.options.numOutputBusChannels = ~serverConf[\hardwareOutputsAmount];
	s.options.sampleRate = ~serverConf[\sampleRate];
	s.options.memSize = ~serverConf[\realTimeMemory];
	s.options.numWireBufs = ~serverConf[\wireBuffersNumber];
	s.waitForBoot({

		s.mute;

		"Initializing kernels".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing kernels");
		~initKernels.value;
		s.sync();

		"Preparing Synth".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Preparing Synth");
		~prepareSynths.value;
		s.sync();

		"Initializing Busses".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Busses");
		~initBuses.value;
		s.sync();

		"Initializing Channels".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Channels");
		~initChannels.value;
		s.sync();

		"Initializing Groups".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Groups");
		~initGroups.value;
		s.sync();

		"Initializing Synths".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Synths");
		~initSynths.value;
		s.sync();

		"Initializing States".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing States");
		~initState.value;
		s.sync();

		~initVM.value;
		s.sync();

		"Starting VolumeMeter".postln;
		~vmSend.play;
		s.sync();

		~saveCurrentState.play;
		s.sync();

		//~vmSend.start;
		//~saveCurrentState.start;
		~sendState.value;

		s.unmute;

		~serverConf[\oscCtrlReady] = true;

		~points[0][\synthGain].get(\gain, {arg gain; ("after start gain " ++ gain).postln;});
		~points[0][\synthPan].get(\distance, {arg gain; ("after start dist " ++ gain).postln;});
	});
};