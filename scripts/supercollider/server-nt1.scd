~initBuses = {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~busSilent = Bus.audio(s,1);
	~busSilentCtrl = Bus.control(s, 1);
	~busTrash = Bus.audio(s,1);
	~busTrashCtrl = Bus.control(s, 1);

	~buses = Dictionary();
	~buses.put(\inputsMono,Array.newClear(~serverConf[\inputsMonoAmount]));
	~buses.put(\inputsAmb,Array.newClear(~serverConf[\inputsAmbAmount]));
	~buses.put(\ambMain, Bus.audio(s, ~serverConf[\ambChansAmount]));
	~buses.put(\ambMainCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
	~buses.put(\outputs,Array.newClear(~serverConf[\outputsAmount]));

	~serverConf[\inputsMonoAmount].do ({
		arg num;
		var item = Dictionary();
		item.put(\in, ~serverConf[\hardwareOutputsAmount] + num);
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\gain,Bus.audio(s,1));
		item.put(\gainCtrl, Bus.control(s, 1));
		item.put(\out, Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\outCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		~buses[\inputsMono][num]=item;
	});
	~buses[\inputsMono].postln;

	~serverConf[\inputsAmbAmount].do ({
		arg num;
		var item = Dictionary();
		item.put(\in, ~serverConf[\hardwareOutputsAmount] + ~serverConf[\inputsMonoAmount] +
			(num - 1) * ~serverConf[\ambChansAmount]);
		item.put(\inCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		item.put(\out,Bus.audio(s, ~serverConf[\ambChansAmount]));
		item.put(\outCtrl, Bus.control(s, ~serverConf[\ambChansAmount]));
		~buses[\inputsAmb][num]=item;
	});
	~buses[\inputsAmb].postln;

	~serverConf[\outputsAmount].do ({
		arg num;
		var item = Dictionary();
		item.put(\in, Bus.audio(s, 1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\out, num - 1);
		item.put(\outCtrl, Bus.control(s, 1));
		~buses[\outputs][num]=item;
	});
	~buses[\output].postln;

};

~initChannels = {

	//Initialise MONO INPUTS
	~inputsMono = Array.newClear(~serverConf[\inputsMonoAmount]);
	~inputsAmb = Array.newClear(~serverConf[\inputsAmbAmount]);

	~serverConf[\inputsMonoAmount].do({
		arg num;
		var input = Dictionary();
		input.put(\name, "Input " ++ (num + 1));
		input.put(\gain, ~defaultValues[\inGain]);
		input.put(\azim, ~defaultValues[\inAzim]);
		input.put(\elev, ~defaultValues[\inElev]);
		input.put(\dist, ~serverConf[\roomRadius]);
		input.put(\mute, ~defaultValues[\inMute]);
		input.put(\volume, ~defaultValues[\inVolume]);
		input.put(\busIn, ~buses[\inputsMono][num][\in]);
		input.put(\busInCtrl, ~buses[\inputsMono][num][\inCtrl]);
		input.put(\busGain, ~buses[\inputsMono][num][\gain]);
		input.put(\busGainCtrl, ~buses[\inputsMono][num][\gainCtrl]);
		input.put(\busOut, ~buses[\inputsMono][num][\out]);
		input.put(\busOutCtrl, ~buses[\inputsMono][num][\outCtrl]);
		~inputsMono[num] = input;
	});
	~inputsMono.postln;

	//Initialise AMBISONIC INPUTS
	~inputsAmb = Array.newClear(~serverConf[\inputsAmbAmount]);
	~serverConf[\inputsAmbAmount].do({
		arg num;
		var input = Dictionary();
		input.put(\busIn, ~buses[\inputsAmb][num][\in]);
		input.put(\busInCtrl, ~buses[\inputsAmb][num][\inCtrl]);
		input.put(\busOut, ~buses[\inputsAmb][num][\out]);
		input.put(\busOutCtrl, ~buses[\inputsAmb][num][\outCtrl]);
		~inputsAmb[num] = input;
	});
	~inputsAmb.postln;
};

//Initialise GROUPS

~initGroups = {

	~grpInputsMono = Group.new(s);
	~grpInputsAmb = Group.after(~grpInputsMono);
	~grpAmbMain = Group.after(~grpInputsAmb);

	~grpInputMono = Array.newClear(~serverConf[\inputsMonoAmount]);
	~grpInputAmb = Array.newClear(~serverConf[\inputsAmbAmount]);

	~serverConf[\inputsMonoAmount].do({
		arg num;
		~grpInputMono[num] = Group.tail(~grpInputsMono);
	});

	~serverConf[\inputsAmbAmount].do({
		arg num;
		~grpInputAmb[num] = Group.tail(~grpInputsAmb);
	});
};

//~grpInputMono[1].postln;

//Initialise SYNTHS

~initSynths = {

	~serverConf[\inputsMonoAmount].do({
		arg num;
		var item = ~inputsMono[num];

		item.put('synthInGain', Synth.new(\inGain,
			[\busIn, item[\busIn],
				\busInCtrl, item[\busInCtrl],
				\busOut, item[\busGain],
				\busOutCtrl, item[\busGainCtrl],
				\gain, ~defaultValues[\inGain]
			],
			~grpInputMono[num],
			\addToTail)
		);
		("init synth gain " ++ ~defaultValues[\inGain]).postln;
		item.put('synthInAmbPan', Synth.new(\ambPan,
			[\busIn, item[\busGain],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl],
				\distance, ~defaultValues[\inDist],
				\radius, ~defaultValues[\inDist].clip(0.1, 1000)
			],
			~grpInputMono[num],
			\addToTail)
		);
		("init synth dist " ++ ~defaultValues[\inDist]).postln;
		item.put('synthInAmbSend', Synth.new(\ambSend,
			[\busIn, item[\busOut],
				\busOut, ~buses[\ambMain],
				\volume, 1
			],
			~grpInputMono[num],
			\addToTail)
		);
	});

	~serverConf[\inputsAmbAmount].do({
		arg num;
		var item = ~inputsAmb[num];

		item.put('synthAmbTransform', Synth.new(\ambTransform,
			[\busIn, item[\busIn],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpInputAmb[num],
			\addToTail)
		);
		item.put('synthInAmbSend', Synth.new(\ambSend,
			[\busIn, item[\busOut],
				\busOut, ~buses[\ambMain],
				\volume, 0
			],
			~grpInputMono[num],
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

		~inputsMono[0][\synthInGain].get(\gain, {arg gain; ("after start gain " ++ gain).postln;});
		~inputsMono[0][\synthInAmbPan].get(\distance, {arg gain; ("after start dist " ++ gain).postln;});
	});
};