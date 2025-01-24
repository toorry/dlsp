
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
	~serverConf.put( \hoaEncRadius, 7);
	~serverConf.put( \mainDirections, [30.0, 135.0, -135.0, -30.0].degrad );
	//~serverConf.put( \mainDirections, [30, 60, 90, 150, -150, -90, -60, -30].degrad );
	~serverConf.put( \hoaBeamShape, \basic );
	~serverConf.put( \hoaMatch, \amp );

	~defaultValues = Dictionary.new();

	~defaultValues.put( \inGain, Dictionary.new() );
	~defaultValues[\inGain].put( \gain, 1.0 );

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
	hoaMatch = ~serverConf.put(\hoaMatch),
	mainWindowWidth = 1024,
	mainWindowHeight = 768;

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

		"Initializing Synths".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Synths");
		~initSynths.value;
		s.sync();

		~initVM.value;
		s.sync();
		"Starting VolumeMeter".postln;
		~vmSend.play;
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
		arg busIn, busInCtrl, busOut, busOutCtrl, gain = 1.0;
		var sig;

		sig = In.ar( busIn, 1 );

		Out.kr( busInCtrl, sig );

		sig = sig * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\ambPan, {
		arg busIn, busOut, busOutCtrl, azimuth = 0, elevation = 0, radius = ~serverConf.put[\hoaEncRadius],
		approach = 0, distance = ~serverConf.put[\hoaEncRadius], mute = 1, volume = 1;
		var sig;

		sig = In.ar(busIn, 1);

		sig = HoaEncodeDirection.ar(sig, azimuth.degrad, elevation.degrad, radius, 1);
		//sig = FoaPanB.ar(sig, azimuth.degrad, elevation.degrad);//DIRECTION
		//sig = FoaDirectO.ar(sig, approach * pi/2);//APPROACH
		sig = sig * volume * 1 / distance;

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
		hoaEncRadius: 1,
		mainDirections: [30.0, 135.0, -135.0, -30.0].degrad,
		hoaBeamShape: \basic,
		hoaMatch: \amp
	);
};