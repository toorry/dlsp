~initBuses = {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~busSilent = Bus.audio(s,1);
	~busSilentCtrl = Bus.control(s, 1);
	~busTrash = Bus.audio(s,1);
	~busTrashCtrl = Bus.control(s, 1);

	~buses = Dictionary();
	~buses.put(\points,Array.newClear(~serverConf[\pointsAmount]));
	~buses.put(\fields,Array.newClear(~serverConf[\fieldsAmount]));
	~buses.put(\ambMain, Bus.audio(s, ~serverConf[\ambChansAmount]));
	~buses.put(\ambMainCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
	~buses.put(\outputs,Array.newClear(~serverConf[\outputsAmount]));

	~serverConf[\pointsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\in, ~hwOutputs + num);
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
		item.put(\in, ~hwOutputs + ~serverConf[\pointsAmount] +
			(num * ~serverConf[\ambChansAmount]));
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

	~serverConf[\outputsAmount].do ({
		arg num;
		var item = Dictionary.new();
		item.put(\in, Bus.audio(s, 1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\out, num - 1);
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
		item.put(\gain, ~defaultValues[\point][\gain]);
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

	//Initialise FIELDS
	~fields = Array.newClear(~serverConf[\fieldsAmount]);

	~serverConf[\fieldsAmount].do({
		arg num;
		var item = Dictionary.new();
		item.put(\name, "Field " ++ (num + 1));
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
};

//Initialise GROUPS

~initGroups = {

	~grpPoints = Group.new(s);
	~grpFields = Group.after(~grpPoints);
	~grpAmbMain = Group.after(~grpFields);

	~grpPoint = Array.newClear(~serverConf[\pointsAmount]);
	~grpField = Array.newClear(~serverConf[\fieldsAmount]);

	~serverConf[\pointsAmount].do({
		arg num;
		~grpPoint[num] = Group.tail(~grpPoints);
	});

	~serverConf[\fieldsAmount].do({
		arg num;
		~grpField[num] = Group.tail(~grpFields);
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
				\distance, ~defaultValues[\point][\dist],
				\radius, ~defaultValues[\point][\dist].clip(0.1, 1000)
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
			\busOut, [0,1],
		],
		~grpAmbMain,
		\addToTail);

	~synthDecoderRoom = Synth.new(\decoderRoom,
		[\busIn, ~buses[\ambMain],
			\busOut, [2,3,4,5,6,7,8,9,10,11],
		],
		~grpAmbMain,
		\addToTail);

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