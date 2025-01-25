
~initConfig = Routine {

	"Declaring server environment".postln;
	~serverConf = Dictionary.new();
	~serverConf.put( \hwInputs, 32 );
	~serverConf.put( \hwOutputs, 14 );

	~serverConf.put( \inputsMonoAmount, 16 );
	~serverConf.put( \inputsAmbAmount, 4 );
	~serverConf.put( \outputsAmount, 16 );

	~serverConf.put( \ambOrder, 1 );
	~serverConf.put( \ambChansAmount, (~serverConf[\ambOrder] + 1).squared );
	~serverConf.put( \hoaEncRadius, 2);
	~serverConf.put( \decoderMainType, "circle" );
	~serverConf.put( \decoderMainSpeakersAmount, 4 );
	~serverConf.put( \mainDirections, [30.0, 135.0, -135.0, -30.0].degrad );
	//~serverConf.put( \mainDirections, [30, 60, 90, 150, -150, -90, -60, -30].degrad );
	~serverConf.put( \hoaBeamShape, \basic );
	~serverConf.put( \hoaMatch, \amp );

	~defaultValues = Dictionary.new();

	~defaultValues.put( \inGain, 1.0 );

	~defaultValues.put( \inGate, Dictionary.new() );
	~defaultValues[\inGate].put( \threshold, 0.01 );
	~defaultValues[\inGate].put( \ratio, 10 );
	~defaultValues[\inGate].put( \attack, 0.01 );
	~defaultValues[\inGate].put( \release, 0.01 );
	~defaultValues[\inGate].put( \dryWet, 1.0 );

	~defaultValues.put( \inEQ, Dictionary.new() );

	~defaultValues[\inEQ].put( \lowCutOn, 0 );
	~defaultValues[\inEQ].put( \lowCutFreq, 100 );
	~defaultValues[\inEQ].put( \lowShelfOn, 1 );
	~defaultValues[\inEQ].put( \lowShelfFreq, 250 );
	~defaultValues[\inEQ].put( \lowShelfQ, 1.0 );
	~defaultValues[\inEQ].put( \lowShelfGain, 0 );
	~defaultValues[\inEQ].put( \band1On, 1 );
	~defaultValues[\inEQ].put( \band1Freq, 250 );
	~defaultValues[\inEQ].put( \band1Q, 1.0 );
	~defaultValues[\inEQ].put( \band1Gain, 0 );
	~defaultValues[\inEQ].put( \band2On, 1 );
	~defaultValues[\inEQ].put( \band2Freq, 600 );
	~defaultValues[\inEQ].put( \band2Q, 1.0 );
	~defaultValues[\inEQ].put( \band2Gain, 0 );
	~defaultValues[\inEQ].put( \band3On, 1 );
	~defaultValues[\inEQ].put( \band3Freq, 1500 );
	~defaultValues[\inEQ].put( \band3Q, 1.0 );
	~defaultValues[\inEQ].put( \band3Gain, 0 );
	~defaultValues[\inEQ].put( \band4On, 1 );
	~defaultValues[\inEQ].put( \band4Freq, 4000 );
	~defaultValues[\inEQ].put( \band4Q, 1.0 );
	~defaultValues[\inEQ].put( \band4Gain, 0 );
	~defaultValues[\inEQ].put( \hiShelfOn, 1 );
	~defaultValues[\inEQ].put( \hiShelfFreq, 4000 );
	~defaultValues[\inEQ].put( \hiShelfQ, 1.0 );
	~defaultValues[\inEQ].put( \hiShelfGain, 0 );
	~defaultValues[\inEQ].put( \hiCutOn, 0 );
	~defaultValues[\inEQ].put( \hiCutFreq, 10000 );
	~defaultValues[\inEQ].put( \dryWet, 1.0 );

	~defaultValues.put( \inAzim, 0 );
	~defaultValues.put( \inElev, 0 );
	~defaultValues.put( \inDist, ~serverConf[\hoaEncRadius] );
	~defaultValues.put( \inMute, 0 );
	~defaultValues.put( \inVolume, 1 );

	~serverConf.put(\states, Dictionary.new());
	~serverConf[\states].put(\saveCurrentRate, 5);
};

~bootConfig = {
	arg hwDevice = "ASIO : Dante Virtual Soundcard (x64)",
	hwInputs = 32, hwOutputs = 14,
	hwSampleRate = 48000,

	memSize = 1048576,

	inputsMonoAmount = 32,
	inputsAmbAmount = 4,
	outputsAmount = 16,

	ambOrder = ~serverConf.put(\ambOrder),
	hoaEncRadius = ~serverConf.put(\hoaEncRadius),
	mainDirections = ~serverConf[\mainDirections],
	hoaBeamShape = ~serverConf.put(\hoaBeamShape),
	hoaMatch = ~serverConf.put(\hoaMatch);

	"Setting server variables".postln;
	~serverConf[\hwInputs] = hwInputs;
	~serverConf[\hwOutputs] = hwOutputs;
	~serverConf[\inputsMonoAmount] = inputsMonoAmount;
	~serverConf[\inputsAmbAmount] = inputsAmbAmount;
	~serverConf[\outputsAmount] = outputsAmount;

	~serverConf[\ambOrder] = ambOrder;
	~serverConf[\ambChansAmount] = (~serverConf[\ambOrder] + 1).squared;

	s.options.device = hwDevice;
	s.options.numInputBusChannels = hwInputs;
	s.options.numOutputBusChannels = hwOutputs;
	s.options.sampleRate = hwSampleRate;
	s.options.memSize = memSize;
	s.options.numWireBufs = 128;
	s.waitForBoot({
		"Initializing kernels".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing kernels");
		~initKernels.value( \mainDirections, mainDirections );
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

		"Initializing States".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing States");
		~initStates.value;
		s.sync();

		"Initializing Synths".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Synths");
		~initSynths.value;
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
	});
};

~initKernels = {

	~encoderBin = FoaEncoderMatrix.newHoa1;
	s.sync();
	~decoderBin = FoaDecoderKernel.newCIPIC;
	s.sync();
	~decoderRoom = FoaDecoderMatrix.newDiametric(~serverConf[\mainDirections]);
	s.sync();
	//~decoderRoom.dirChannels = ~serverConf[\mainDirections];

	//~ambEncBinaural = FoaEncoderMatrix.newHoa1;
	//s.sync();
	//~ambDecBinaural = FoaDecoderKernel.newCIPIC;
	//s.sync();
};

~prepareSynths = {

	SynthDef(\inGain, {
		arg busIn, busInCtrl, busOut, busOutCtrl, gain = ~defaultValues[\inGain];
		var sig;

		sig = In.ar( busIn, 1 );

		Out.kr( busInCtrl, sig );

		sig = sig * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\ambPan, {
		arg busIn, busOut, busOutCtrl, azimuth = 0, elevation = 0, radius = ~serverConf[\hoaEncRadius],
		approach = 0, distance = ~serverConf[\hoaEncRadius], mute = 1, volume = 1;
		var sig;

		sig = In.ar(busIn, 1);

		sig = HoaEncodeDirection.ar(sig, azimuth.degrad, elevation.degrad, radius, 1);
		//sig = FoaPanB.ar(sig, azimuth.degrad, elevation.degrad);//DIRECTION
		//sig = FoaDirectO.ar(sig, approach * pi/2);//APPROACH
		sig = sig * volume * ~serverConf[\hoaEncRadius] / distance;

		Out.ar(busOut, sig * mute);
		Out.kr(busOutCtrl, sig);
	}).add;

	SynthDef(\ambTransform, {
		arg busIn, busOut, busOutCtrl, rotateAngle = 0, tiltAngle = 0, tumbleAngle = 0, mute = 1, volume = 1;
		var sig;

		sig = In.ar(busIn, 4);
		sig = FoaRTT.ar(sig, rotateAngle.degrad, tiltAngle.degrad, tumbleAngle.degrad);
		sig = sig * volume;

		Out.ar(busOut, sig * mute);
		Out.kr(busOutCtrl, sig);
	}).add;

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

	SynthDef(\decoderBin, {
		arg busIn, busOut, busOutCtrl;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		sig = FoaDecode.ar(  // decode to binaural
			FoaProximity.ar(  // exchange (reference radius)
				HPF.ar(  // pre-condition FOA
					FoaEncode.ar(  // exchange (ordering, normalisation)
						sig.keep(AtkFoa.defaultOrder.asHoaOrder.size),  // truncate to HOA1
						~encoderBin
					),
					30.0 //highpass frequency
				),
				AtkHoa.refRadius
			),
			~decoderBin
		);
		//sig = FoaDecode.ar(sig, ~decoderBin);

		Out.ar( busOut, sig );
		//Out.kr( busOutCtrl, sigOut );
	}).add;

	SynthDef(\monoSend, {
		arg busIn, busOut, volume;
		var sig;

		sig = In.ar( busIn, 1 );

		Out.ar( busOut, sig * volume );
	}).add;

	SynthDef(\ambSend, {
		arg busIn, busOut, volume = 0;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		Out.ar( busOut, sig * volume );
	}).add;
};

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
		item.put(\in, ~serverConf[\hwOutputs] + num);
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
		item.put(\in, ~serverConf[\hwOutputs] + ~serverConf[\inputsMonoAmount] +
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
		input.put(\dist, ~serverConf[\hoaEncRadius]);
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


//Initialise STATE

~initStates = {

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
	~stateCurrent[\decoderMain].put(\radius, ~serverConf[\hoaEncRadius]);
	~stateCurrent[\decoderMain].put(\speakersAmount, ~serverConf[\decoderMainSpeakersAmount]);
	~stateCurrent[\decoderMain].put(\directions, ~serverConf[\mainDirections]);
	~stateCurrent[\decoderMain].put(\mute, 1);

	~loadState.value;
};

//Initialise SYNTHS

~initSynths = {

	~serverConf[\inputsMonoAmount].do({
		arg num;
		var item = ~inputsMono[num];

		item.put('synthInGain', Synth.new(\inGain,
			[\busIn, item[\busIn],
				\busInCtrl, item[\busInCtrl],
				\busOut, item[\busGain],
				\busOutCtrl, item[\busGainCtrl]
			],
			~grpInputMono[num],
			\addToTail)
		);
		item.put('synthInAmbPan', Synth.new(\ambPan,
			[\busIn, item[\busGain],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpInputMono[num],
			\addToTail)
		);
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

~initVM = {
	~vm = Dictionary.new();
	~vmOpt = Dictionary.new();
	~vmBuff = Dictionary.new();

	~vmOpt.put(\rate, 0.3);
	~vmOpt.put(\packMaxSize, 16);

	~vmBuff.put(\ambBuffer, Array.newClear(~serverConf[\ambChansAmount]));
	~vmBuff.put(\msg, Array.newClear(1));

	~vm.put(\inputsMono, Dictionary.new());  //Inputs MONO
	~vm.put(\inputsAmb, Dictionary.new());  //Inputs AMBISONIC
	~vm.put(\outputs, Dictionary.new()); //Outputs

	~vm[\inputsMono].put(\in, List.newUsing([1,2,3,4]));
	~vm[\inputsMono].put(\gain, List.newUsing([1,2,3,4]));
	~vm[\inputsMono].put(\out, List.newUsing([1,2]));

	~vm[\inputsAmb].put(\in, List.newClear());
	~vm[\inputsAmb].put(\out, List.newClear());

	~vm[\outputs].put(\in, List.newClear());

	~vm.postln;
};

~vmSend = Routine {
	var value;
	"vmSend".postln;
	loop {
		//"vm".postln;
		~vm.keys.do ({
			arg chanType;
			//(' '++chanType).postln;
			~vm[chanType].keys.do ({
				arg busType;
				//('  '++busType).postln;
				~vm[chanType][busType].do ({
					arg value;
					//(value + " ").post;
					(
						switch (busType,
							\in, {//INPUT BUS
								~ostagec.sendMsg("/v", "i", "in", value,
									~buses[\inputsMono][value-1][\inCtrl].getSynchronous.abs);
							},
							\gain, {//GAIN BUS
								~ostagec.sendMsg("/v", "i", "gn", value,
									~buses[\inputsMono][value-1][\gainCtrl].getSynchronous.abs);
							},
							\out, {//OUT BUS
								~vmBuff[\msg] = ["/v", "i", "ot", value] ++
								~buses[\inputsMono][value-1][\outCtrl].getnSynchronous(4).abs;
								~ostagec.sendMsg(*~vmBuff[\msg]);
							}
						);
					)
				});
			});
		});
		~vmOpt[\rate].wait;
	};
};

~saveCurrentState = Routine {
	loop {
		File.use(~path +/+ "states" +/+ "current.dlspstate", "w", { |f|
			f.write(JSONlib.convertToJSON(~stateCurrent).postln);
		});
		~serverConf[\states][\saveCurrentRate].wait;
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
		~stateLoaded = JSONlib.parseFile(~path +/+ "states" +/+ "current.dlspstate");

		try {
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
										~inputsMono[num][\synthInAmbPan].set(\radius, ~inputsMono[num][\dist].clip(0.1,1000),
											\distance, ~inputsMono[num][\dist].clip(~serverConf.put[\hoaEncRadius],1000));
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
	} {}
};

~regularBoot = Routine {


	~bootConfig.value(
		hwInputs: 8, hwOutputs: 10,
		hwDevice: "ASIO : UMC ASIO Driver",
		//hwDevice: "ASIO : Dante Virtual Soundcard (x64)",
		hwSampleRate: 48000,
		memSize: 1048576,
		inputsMonoAmount: 4,
		inputsAmbAmount: 1,
		outputsAmount: 14,

		ambOrder: 1,
		hoaEncRadius: ~serverConf.put( \hoaEncRadius, 7);,
		mainDirections: ~serverConf[\mainDirections],
		hoaBeamShape: \basic,
		hoaMatch: \amp
	);
};