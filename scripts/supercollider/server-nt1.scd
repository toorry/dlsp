
~initConfig = Routine {

	"Declaring server environment".postln;
	~serverConf = Dictionary.new();
	~serverConf.put( \hwInputs, 32 );
	~serverConf.put( \hwOutputs, 12 );

	~serverConf.put( \inputsMonoAmount, 16 );
	~serverConf.put( \inputsAmbAmount, 4 );
	~serverConf.put( \outputsAmount, 16 );

	~ambOrder = 1;

	~vm;
	~vmRate;
	~vmPackMaxSize;

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
	arg hwInputs = 32, hwOutputs = 12,
	hwInDevice = "BlackHole 64ch",
	hwOutDevice = "BlackHole 64ch",
	hwSampleRate = 48000,

	memSize = 1048576,

	inputsMonoAmount = 32,
	inputsAmbAmount = 4,
	outputsAmount = 16,

	ambOrder = 1,

	mainWindowWidth = 1024,
	mainWindowHeight = 768;

	"Setting server variables".postln;
	~hwInputs = hwInputs;
	~hwOutputs = hwOutputs;
	~inputsMonoAmount = inputsAmount;
	~inputsAmbAmount = inputsAmbAmount;
	~outputsAmount = outputsAmount;

	~ambOrder = ambOrder;
	~ambChansAmount = (~ambOrder + 1).squared;

	~windowHeight = mainWindowHeight;
	~windowWidth = mainWindowWidth;

	~vmRate = 0.3;

	s.options.numInputBusChannels = ~hwInputs;
	s.options.numOutputBusChannels = ~hwOutputs;
	s.options.sampleRate = hwSampleRate;
	s.options.memSize = memSize;
	s.waitForBoot({
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

		~initVM.value;
		s.sync();
		"Starting VolumeMeter".postln;
		~vmSend.play;
	});
};

/*~initKernels = {

	~ambEncBinaural = FoaEncoderMatrix.newHoa1;
	s.sync();
	~ambDecBinaural = FoaDecoderKernel.newCIPIC;
	s.sync();
};*/

~prepareSynths = {

	SynthDef(\inGain, {
		arg busIn, busOut, busOutCtrl, gain = 1.0;
		var sig;

		sig = In.ar( busIn, 1 ) * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\chanOut, {
			arg busIn, busOutPre, busOutPreCtrl, busOut, busOutCtrl, volume = 1.0, unmute = 1.0;
			var sig;

			sig = In.ar( busIn, 1 );

			Out.ar( busOutPre, sig * unmute );
			Out.ar( busOut, sig * volume * unmute );
			Out.kr( busOutPre, sig );
			Out.kr( busOut,sig * volume );
		}).add;

	SynthDef(\ambPan, {
		arg busIn, busOut, busOutCtrl, amp=0, angRot = 0, angElev = 0, omni = 0;
		var sndIn, sndFr, sndBk, sndHoa, amp1, amp2;
		sndIn = In.ar(busIn, 1);
		amp1 = amp * (1 -omni);
		amp2 = omni * amp / 2;
		sndFr = HoaEncodeDirection.ar(sndIn * amp1, angRot, angElev, ~hoaEncRadius, ~hoaOrder);
		sndBk = HoaEncodeMatrix.ar((sndIn * amp2)!4, HoaMatrixEncoder.newDirections(
			[[0,pi/2],[0,-0.6154797],[pi*1.5,-0.6154797],[-pi*1.5,-0.6154797]],
			~hoaBeamShape, ~hoaMatch, ~hoaOrder));
		sndHoa = Mix.new([sndFr, sndBk]);

		Out.ar(busOut, sndHoa);
		Out.kr(busOutCtrl, sndHoa);
	}).add;

	SynthDef(\ambTransform, {
		arg busIn, busOut, busOutCtrl, amp=0, angRot = 0, angElev = 0, omni = 0;
		var sndIn, sndFr, sndBk, sndHoa, amp1, amp2;
		sndIn = In.ar(busIn, 1);
		amp1 = amp * (1 -omni);
		amp2 = omni * amp / 2;
		sndFr = HoaEncodeDirection.ar(sndIn * amp1, angRot, angElev, ~hoaEncRadius, ~hoaOrder);
		sndBk = HoaEncodeMatrix.ar((sndIn * amp2)!4, HoaMatrixEncoder.newDirections(
			[[0,pi/2],[0,-0.6154797],[pi*1.5,-0.6154797],[-pi*1.5,-0.6154797]],
			~hoaBeamShape, ~hoaMatch, ~hoaOrder));
		sndHoa = Mix.new([sndFr, sndBk]);

		Out.ar(busOut, sndHoa);
		Out.kr(busOutCtrl, sndHoa);
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
	~buses.put(\hwIn,Array.newClear(~hwInputs));
	~buses.put(\hwOut,Array.newClear(~hwOutputs));
	~buses.put(\inputsMono,Array.newClear(~inputsMonoAmount));
	~buses.put(\inputsAmb,Array.newClear(~inputsAmbAmount));
	~buses.put(\outputs, Array.newClear(~outputsAmount));

	~hwInputs.do ({
		arg num;
		~buses[\hwIn][num] = Dictionary.new();
		~buses[\hwIn][num].put(\in, ~hwOutputs + num);
		~buses[\hwIn][num].put(\inCtrl, Bus.control(s, 1));
		~buses[\hwIn][num].put(\out, Bus.audio(s, 1));
		~buses[\hwIn][num].put(\outCtrl, Bus.control(s, 1));
	});
	~buses[\hwIn].postln;

	~hwOutputs.do ({
		arg num;
		~buses[\hwOut][num] = Dictionary.new();
		~buses[\hwOut][num].put(\in, Bus.audio(s, 1));
		~buses[\hwOut][num].put(\inCtrl, Bus.control(s, 1));
		~buses[\hwOut][num].put(\out, num);
		~buses[\hwOut][num].put(\outCtrl, Bus.control(s, 1));
	});
	~buses[\hwOut].postln;

	~inputsMonoAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\outPre,Bus.audio(s,1));
		item.put(\outPreCtrl, Bus.control(s, 1));
		item.put(\out,Bus.audio(s,1));
		item.put(\outCtrl, Bus.control(s, 1));
		item.put(\ambPan, Bus.audio(s, ~ambChansAmount));
		item.put(\ambPanCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\inputsMono][num]=item;
	});
	~buses[\inputsMono].postln;

	~inputsAmbAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s, ~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\ambTransform, Bus.audio(s, ~ambChansAmount));
		item.put(\ambTransformCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\outPre,Bus.audio(s, ~ambChansAmount));
		item.put(\outPreCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\out,Bus.audio(s, ~ambChansAmount));
		item.put(\outCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\inputsAmb][num]=item;
	});
	~buses[\inputsAmb].postln;

	~outputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.newFrom(~buses[\outputs], num, 1));
		item.put(\inCtrl, Bus.newFrom(~buses[\outputsCtrl], num, 1));
		item.put(\out,Bus.audio(s, 1));
		item.put(\outCtrl, Bus.control(s, 1));
		~buses[\outputs][num]=item;
	});
	~buses[\output].postln;

};

~initChannels = {

	//Initialise MONO INPUTS
	~inputsMono = Array.newClear(~inputsMonoAmount);
	~inputsMonoAmount.do({
		arg num;
		var input = Dictionary();
		input.put(\busIn, ~buses[\inputsMono][num][\in]);
		input.put(\busInCtrl, ~buses[\inputsMono][num][\inCtrl]);
		input.put(\busOutPre, ~buses[\inputsMono][num][\outPre]);
		input.put(\busOutPreCtrl, ~buses[\inputsMono][num][\outPreCtrl]);
		input.put(\busOut, ~buses[\inputsMono][num][\out]);
		input.put(\busOutCtrl, ~buses[\inputsMono][num][\outCtrl]);
		input.put(\busAmbPan, ~buses[\inputsMono][num][\ambPan]);
		input.put(\busAmbPanCtrl, ~buses[\inputsMono][num][\ambPanCtrl]);
		~inputsMono[num] = input;
	});
	~inputsMono.postln;

	//Initialise AMBISONIC INPUTS
	~inputsAmb = Array.newClear(~inputsAmbAmount);
	~inputsAmbAmount.do({
		arg num;
		var input = Dictionary();
		input.put(\busIn, ~buses[\inputsAmb][num][\in]);
		input.put(\busInCtrl, ~buses[\inputsAmb][num][\inCtrl]);
		input.put(\busAmbTransform, ~buses[\inputsAmb][num][\ambTransform]);
		input.put(\busAmbTransformCtrl, ~buses[\inputsAmb][num][\ambTransformCtrl]);
		input.put(\busOutPre, ~buses[\inputsAmb][num][\outPre]);
		input.put(\busOutPreCtrl, ~buses[\inputsAmb][num][\outPreCtrl]);
		input.put(\busOut, ~buses[\inputsAmb][num][\out]);
		input.put(\busOutCtrl, ~buses[\inputsAmb][num][\outCtrl]);
		~inputsAmb[num] = input;
	});
	~inputsAmb.postln;

	//Initialise OUTPUTS
	~outputs = Array.newClear(~outputsAmount);
	~outputsAmount.do({
		arg num;
		var output = Dictionary();
		output.put(\busIn, ~buses[\outputs][num][\in]);
		output.put(\busInCtrl, ~buses[\outputs][num][\inCtrl]);
		output.put(\busOut, ~buses[\outputs][num][\out]);
		output.put(\busOutCtrl, ~buses[\outputs][num][\outCtrl]);
		~outputs[num] = output;
	});
	~outputs.postln;
};

//Initialise GROUPS

~initGroups = {

	~grpInputsMono = Group.new();
	~grpInputsAmb = Group.after(~grpInputsMono);
	~grpOutputs = Group.after(~grpInputsAmb);

	//~grpInputsMono = Array.newClear(~inputsMonoAmount);
	//~grpInputsAmb = Array.newClear(~inputsAmbAmount);
	//~grpOutputs = Array.newClear(~outputsAmount);

	~inputsMonoAmount.do({
		arg num;
		~grpInputMono[num] = Group.new(~grpInputsMono, \addToTail);
	});

	~inputsAmbAmount.do({
		arg num;
		~grpInputAmb[num] = Group.new(~grpInputsAmb, \addToTail);
	});

	~outputsAmount.do({
		arg num;
		~grpOutput[num] = Group.new(~grpOutputs, \addToTail);
	});
};

//Initialise SYNTHS

~initSynths = {

	~inputsMonoAmount.do({
		arg num;
		var item = ~inputsMono[num];

		item.put('synthOut', Synth(\chanOut,
			[\busIn, item[\busIn],
				\busOutPre, item[\busOutPre],
				\busOutPreCtrl, item[\busOutPreCtrl],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpInputMono[num],
			\addToTail)
		);
		item.put('synthAmbPan', Synth(\ambPan,
			[\busIn, item[\busOut],
				\busOut, item[\busAmbPan],
				\busOutCtrl, item[\busAmbPanCtrl]
			],
			~grpInputMono[num],
			\addToTail)
		);
	});

	~inputsAmbAmount.do({
		arg num;
		var item = ~inputsAmb[num];

		item.put('synthAmbTransform', Synth(\ambTransform,
			[\busIn, item[\busIn],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpInputAmb[num],
			\addToTail)
		);
	});

	~outputsAmount.do({
		arg num;
		var item = ~outputs[num];

		item.put('synthOut', Synth(\chanOut,
			[\busIn, item[\busIn],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpOutput[num],
			\addToTail)
		);
	});

};

~initVM = {
	~vm = Dictionary.new();
	~vm.put(\inputsMono, Dictionary.new());  //Inputs MONO
	~vm.put(\inputsAmb, Dictionary.new());  //Inputs AMBISONIC
	~vm.put(\outputs, Dictionary.new()); //Outputs

	~vm[\inputsMono].put(\in, List.newClear());
	~vm[\inputsMono].put(\outPre, List.newClear());
	~vm[\inputsMono].put(\out, List.newClear());
	~vm[\inputsMono].put(\ambPan, List.newClear());

	~vm[\inputsAmb].put(\in, List.newClear());
	~vm[\inputsAmb].put(\out, List.newClear());

	~vm[\outputs].put(\in, List.newClear());
	~vm[\outputs].put(\out, List.newClear());

	~vm.postln;
};

~vmSend = Routine {
	var value;
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
							\outPre, {//PREFADER OUT BUS
								~ostagec.sendMsg("/v", "i", "op", value,
									~buses[\inputsMono][value-1][\outCtrl].getSynchronous.abs);
							},
							\out, {//OUT BUS
								~ostagec.sendMsg("/v", "i", "ot", value,
									~buses[\inputsMono][value-1][\outCtrl].getSynchronous.abs);
							},
							\ambPan, {//AMBISONIC PAN BUS
								~ostagec.sendMsg("/v", "i", "ap", value[1], value[0],
									~buses[\input][value[0]-1][\mixSendCtrl][value[1]].getSynchronous.abs);
							},
						);
					)
				});
			});
		});
		~vmRate.wait;
	};
};

//~vuSend.play;
//~vuSend.stop;
//~vuSend.reset;
//OSCFunc.trace(false);
~regularBoot = Routine {

	~initConfig.value;
	~bootConfig.value(
		hwInputs: 2, hwOutputs: 2,
		//hwInDevice: "Windows WASAPI : Microphone Array (AMD Audio Device)",
		//hwInDevice: "Windows WASAPI : CABLE Output (VB-Audio Virtual Cable)",
		//hwOutDevice: "Windows WASAPI : Line (Realphones System-Wide)",
		hwSampleRate: 48000,
		memSize: 1048576,
		inputsAmount: 4,
		mixesAmount: 4,
		pointsAmount: 4,
		fieldsAmount: 1,
		spacesAmount: 1,
		outputsAmount: 4,

		ambOrder: 3,
		hoaEncRadius: 1,
		hoaDirections: [30.0, 135.0, -135.0, -30.0].degrad,
		hoaBeamShape: \basic,
		hoaMatch: \amp,

		mainWindowWidth: 750,
		mainWindowHeight: 550;
	);
};

//~mixes;


{
// z and y are the same object
var y, z;
z = [1, 2, 3];
y = z.add(4);
z.postln;
y.postln;
};

{
// in this case a new object is returned
var y, z;
z = [1, 2, 3, 4, 6];
z.add(5);

z.postln;
y.postln;
z.removeAt(2);
z.postln;
}