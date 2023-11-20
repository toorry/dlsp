
~initConfig = {

	~hwInputs;
	~hwOutputs;

	~inputsAmount;
	~mixesAmount;
	~pointsAmount;
	~fieldsAmount;
	~spacesAmount;
	~outputsAmount;
	~decodersAmount;

	~ambOrder;
	~hoaOrder;
	~ambChansAmount;
	~hoaEncRadius;
	~hoaDirections;
	~hoaBeamShape;
	~hoaMatch;

	~ambEncBinaural;
	~ambDecBinaural;

	~windowHeight;
	~windowWidth;

	~lvlIndicatorRate = 0.1;
};

~bootConfig = {
	arg hwInputs = 2, hwOutputs = 2,
	//hwInDevice = "Windows WASAPI : Microphone Array (AMD Audio Device)",
	//hwOutDevice = "Windows WASAPI : Line (Realphones System-Wide)",
	hwSampleRate = 48000,

	memSize = 1048576,

	inputsAmount = 4,
	mixesAmount = 4,
	pointsAmount = 4,
	fieldsAmount = 1,
	spacesAmount = 1,
	outputsAmount = 4,
	decodersAmount = 2,

	ambOrder = 1,
	hoaEncRadius = 1,
	hoaDirections = [45.0, 135.0, -135.0, -45.0].degrad,
	hoaBeamShape = \basic,
	hoaMatch = \amp,

	mainWindowWidth = 1024,
	mainWindowHeight = 768;

	~hwInputs = hwInputs;
	~hwOutputs = hwOutputs;
	~inputsAmount = inputsAmount;
	~mixesAmount = mixesAmount;
	~pointsAmount = pointsAmount;
	~fieldsAmount = fieldsAmount;
	~spacesAmount = spacesAmount;
	~outputsAmount = outputsAmount;
	~decodersAmount = decodersAmount;

	~ambOrder = ambOrder;
	~hoaOrder = ~ambOrder;
	~ambChansAmount = (~ambOrder + 1).squared;
	~hoaEncRadius = hoaEncRadius;
	~hoaDirections = hoaDirections;
	~hoaBeamShape = hoaBeamShape;
	~hoaMatch = hoaMatch;

	~windowHeight = mainWindowHeight;
	~windowWidth = mainWindowWidth;

	s.options.numInputBusChannels = ~hwInputs;
	s.options.numOutputBusChannels = ~hwOutputs;
	//s.options.inDevice = hwInDevice;
	//s.options.outDevice = hwOutDevice;
	s.options.sampleRate = hwSampleRate;
	s.options.memSize = memSize;
	s.boot;
};

~initKernels = Routine {

	~ambEncBinaural = FoaEncoderMatrix.newHoa1;
	s.sync;
	~ambDecBinaural = FoaDecoderKernel.newCIPIC;
	s.sync;
};

~prepareSynths = Routine {

	SynthDef(\outVolume, {
		arg busIn, busOut, busOutCtrl, isAmb = 0, amp = 0;
		var sig;

		if(isAmb == 1) {
			switch(~ambOrder)
			{1}{ sig = In.ar(busIn,4) * amp; }
			{2}{ sig = In.ar(busIn,9) * amp; }
			{3}{ sig = In.ar(busIn,16) * amp; }
			{ sig = In.ar(busIn,1) * amp; };
		}
		{ sig = In.ar(busIn,1) * amp; };
		Out.ar(busOut, sig);
		Out.kr(busOutCtrl, sig);
	}).add;
	s.sync;

	SynthDef(\ambPan, {
		arg busIn, busOut, busOutCtrl, amp=0, angRot = 0, angElev = 0, omni = 0;
		var sndIn, sndFr, sndBk, sndHoa, amp1, amp2;
		sndIn = In.ar(busIn, 1);
		//amp1 = amp * (2 - omni) / 2;
		//amp2 = 1 - amp * omni / 2;
		//amp1 = 0.01;
		amp1 = amp * (1 -omni);
		//amp2 = 0.01;
		amp2 = omni * amp / 2;
		sndFr = HoaEncodeDirection.ar(sndIn * amp1, angRot, angElev, ~hoaEncRadius, ~hoaOrder);
		sndBk = HoaEncodeMatrix.ar((sndIn * amp2)!4, HoaMatrixEncoder.newDirections(
			[[0,pi/2],[0,-0.6154797],[pi*1.5,-0.6154797],[-pi*1.5,-0.6154797]],
			~hoaBeamShape, ~hoaMatch, ~hoaOrder));
		sndHoa = Mix.new([sndFr, sndBk]);

		Out.ar(busOut, sndHoa);
		Out.kr(busOutCtrl, sndHoa);
	}).add;
	s.sync;

	SynthDef(\ambDecSpeakers, {
		arg busIn, busOut, busOutCtrl, amp=0;
		var sndIn;

		sndIn = In.ar(busIn,~ambChansAmount);

		sndIn = HoaDecodeMatrix.ar(sndIn, HoaMatrixDecoder.newModeMatch(
		~hoaDirections,
		beamShape: ~hoaBeamShape,
		match: ~hoaMatch,
		order: ~hoaOrder));

		Out.ar(busOut, sndIn);
		Out.kr(busOutCtrl, sndIn);
	}).add;
	s.sync;

	/*SynthDef(\ambDecBinaural, {
		arg busIn, busOut, busOutCtrl, amp=0;
		var sndIn;

		sndIn = In.ar(busIn,~ambChansAmount);

		sndIn = FoaDecode.ar(
			FoaProximity.ar(
				FoaEncode.ar(
					sndIn.keep(AtkFoa.defaultOrder.asHoaOrder.size),
					~ambEncBinaural
				),
				AtkHoa.refRadius
			),
			~ambDecBinaural);

		Out.ar(busOut, sndIn);
		Out.ar(busOutCtrl, sndIn);
	}).add;*/
	s.sync;
};

~initBuses = Routine {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~busSilent = Bus.audio(s,1);
	~busSilentCtrl = Bus.control(s, 1);
	~busTrash = Bus.audio(s,1);
	~busTrashCtrl = Bus.control(s, 1);
	s.sync;
	~buses = Dictionary();
	~buses.put(\hwIn,Array.newClear(~hwInputs));
	~buses.put(\hwInCtrl,Array.newClear(~hwInputs));
	~buses.put(\hwOut,Array.newClear(~hwOutputs));
	~buses.put(\hwOutCtrl,Array.newClear(~hwOutputs));
	~buses.put(\input,Array.newClear(~inputsAmount));
	~buses.put(\mix,Array.newClear(~mixesAmount));
	~buses.put(\point,Array.newClear(~pointsAmount));
	~buses.put(\field,Array.newClear(~fieldsAmount));
	~buses.put(\space, Array.newClear(~spacesAmount));
	~buses.put(\output, Array.newClear(~outputsAmount));
	s.sync;
	~hwInputs.do ({
		arg num;
		~buses[\hwIn][num] = ~hwOutputs + num;
		~buses[\hwInCtrl][num] = Bus.control(s, 1);
	});
	~buses[\hwIn].postln;
	s.sync;
	~hwOutputs.do ({
		arg num;
		~buses[\hwOut][num] = num;
		~buses[\hwOutCtrl][num] = Bus.control(s, 1);
	});
	~buses[\hwOut].postln;
	s.sync;
	~inputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		~buses[\input][num]=item;
	});
	~buses[\input].postln;
	s.sync;
	~mixesAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		~buses[\mix][num]=item;
	});
	~buses[\mix].postln;
	s.sync;
	~pointsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		~buses[\point][num]=item;
	});
	~buses[\point].postln;
	s.sync;
	~fieldsAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\field][num] = item;
	});
	~buses[\field].postln;
	s.sync;
	~spacesAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\space][num] = item;
	});
	~buses[\space].postln;
	s.sync;
	~buses.put(\outputs, Bus.audio(s, ~outputsAmount));
	~buses.put(\outputsCtrl, Bus.control(s, ~outputsAmount));
	s.sync;
	~outputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.newFrom(~buses[\outputs], num, 1));
		item.put(\inCtrl, Bus.newFrom(~buses[\outputsCtrl], num, 1));
		~buses[\output][num]=item;
	});
	~buses[\output].postln;
	s.sync;
};

~initChannels = Routine {

	//Initialise INPUTS
	~inputs = Array.newClear(~inputsAmount);
	~inputsAmount.do({
		arg num;
		var input = Dictionary();
		if(num < ~hwInputs)
		{input.put(\busIn,~buses[\hwIn][num])} //then
		{input.put(\busIn,~busSilent)}; //else
		//input.put(\outVolume,Bus(audio(s,1)));
		~inputs[num] = input;
	});
	~inputs.postln;
	s.sync;

	//Initialise MIXES
	~mixes = Array.newClear(~mixesAmount);
	~mixesAmount.do({
		arg num;
		var mix = Dictionary();
		mix.put(\busIn,~buses[\mix][num][\in]);
		mix.put(\busInCtrl,~buses[\mix][num][\inCtrl]);
		//input.put(\outVolume,Bus(audio(s,1)));
		~mixes[num] = mix;
	});
	~mixes.postln;
	s.sync;

	//Initialise POINTS
	~points = Array.newClear(~pointsAmount);
	~pointsAmount.do({
		arg num;
		var point = Dictionary();
		point.put(\busIn,~buses[\point][num][\in]);
		point.put(\busInCtrl,~buses[\point][num][\inCtrl]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~points[num] = point;
	});
	~points.postln;
	s.sync;

	~fields = Array.newClear(~fieldsAmount);
	~fieldsAmount.do({
		arg num;
		var field = Dictionary();
		field.put(\busIn,~buses[\field][num][\in]);
		field.put(\busInCtrl,~buses[\field][num][\inCtrl]);
		//point.put(\busInCtrl,~buses[\point][num][\inCtrl]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~fields[num] = field;
	});
	s.sync;

	~spaces = Array.newClear(~spacesAmount);
	~spacesAmount.do({
		arg num;
		var space = Dictionary();
		space.put(\busIn,~buses[\space][num][\in]);
		space.put(\busInCtrl,~buses[\space][num][\inCtrl]);
		//point.put(\busInCtrl,~buses[\point][num][\inCtrl]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~spaces[num] = space;
	});
	s.sync;

	//Initialise OUTPUTS
	~outputs = Array.newClear(~outputsAmount);
	~outputsAmount.do({
		arg num;
		var output = Dictionary();
		output.put(\busIn,~buses[\output][num][\in]);
		output.put(\busInCtrl,~buses[\output][num][\inCtrl]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~outputs[num] = output;
	});
	~outputs.postln;
	s.sync;
};

//Initialise GROUPS

~initGroups = Routine {

	~grpHwInputs = Group.new;
	~grpInputs = Group.after(~grpHwInputs);
	~grpMixes = Group.after(~grpInputs);
	~grpPoints = Group.after(~grpMixes);
	~grpFields = Group.after(~grpPoints);
	~grpSpaces = Group.after(~grpFields);
	~grpOutputs = Group.after(~grpSpaces);
	~grpHwOutputs = Group.after(~grpInputs);
	s.sync;
	~grpInput = Array.newClear(~inputsAmount);
	~grpMix = Array.newClear(~mixesAmount);
	~grpPoint = Array.newClear(~pointsAmount);
	~grpField = Array.newClear(~fieldsAmount);
	~grpSpace = Array.newClear(~spacesAmount);
	~grpOutput = Array.newClear(~outputsAmount);
	s.sync;
	~inputsAmount.do({
		arg num;
		~grpInput[num] = Group.new(~grpInputs, \addToTail);
	});
	s.sync;
	~mixesAmount.do({
		arg num;
		~grpMix[num] = Group.new(~grpMixes, \addToTail);
	});
	s.sync;
	~pointsAmount.do({
		arg num;
		~grpPoint[num] = Group.new(~grpPoints, \addToTail);
	});
	s.sync;
	~fieldsAmount.do({
		arg num;
		~grpField[num] = Group.new(~grpFields, \addToTail);
	});
	s.sync;
	~spacesAmount.do({
		arg num;
		~grpSpace[num] = Group.new(~grpSpaces, \addToTail);
	});
	s.sync;
	~outputsAmount.do({
		arg num;
		~grpOutput[num] = Group.new(~grpOutputs, \addToTail);
	});
	s.sync;
};

//Initialise SYNTHS

~initSynths = Routine {

	~inputsAmount.do({
		arg num;
		var item = ~inputs[num];
		~mixesAmount.do({
			arg count;
			var name = 'mix' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item.at(\busIn),
					\busOut, ~mixes[count][\busIn],
					\busOutCtrl, ~mixes[count][\busInCtrl]
				],
				~grpInput[num],
				\addToTail)
			);
		});
		~pointsAmount.do({
			arg count;
			var name = 'point' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item.at(\busIn),
					\busOut, ~points[count][\busIn],
					\busOutCtrl, ~points[count][\busInCtrl]
				],
				~grpInput[num],
				\addToTail)
			);
		});
	});
	s.sync;

	~mixesAmount.do({
		arg num;
		var item = ~mixes[num];
		~pointsAmount.do({
			arg count;
			var name = 'point' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item.at(\busIn),
					\busOut, ~points[count][\busIn],
					\busOutCtrl, ~points[count][\busInCtrl]
				],
				~grpMix[num],
				\addToTail)
			);
		});
	});
	s.sync;

	~pointsAmount.do({
		arg num;
		var item = ~points[num];
		~outputsAmount.do({
			arg count;
			var name = 'output' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item.at(\busIn),
					\busOut, ~buses[\output][count][\in],
					\busOutCtrl, ~buses[\output][count][\inCtrl]
				],
				~grpPoint[num],
				\addToTail)
			);
		});
		~fieldsAmount.do({
			arg count;
			var name = 'field' ++ count ++ 'ambPanSynth';
			item.put(name, Synth(\ambPan,
				[\busIn, item.at(\busIn),
					\busOut, ~buses[\field][count][\in],
					\busOutCtrl, ~buses[\field][count][\inCtrl]
				],
				~grpPoint[num],
				\addToTail)
			);
		});
		~spacesAmount.do({
			arg count;
			var name = 'space' ++ count ++ 'ambPanSynth';
			item.put(name, Synth(\ambPan,
				[\busIn, item.at(\busIn),
					\busOut, ~buses[\space][count][\in],
					\busOutCtrl, ~buses[\space][count][\inCtrl]
				],
				~grpPoint[num],
				\addToTail)
			);
		});
	});
	s.sync;

	~fieldsAmount.do({
		arg num;
		var item = ~fields[num];
		~spacesAmount.do({
			arg count;
			var name = 'space' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item[\busIn],
				\busOut, ~buses[\space][count][\in],
				\isAmb, 1],
				~grpField[num],
				\addToTail)
			);
		});
		/*item.put(\outputsSend, Synth(\outVolume,
			[\busIn, item[\busIn],
			\busOut, ~buses[\output][0][\in],
			\isAmb, 1],
			~grpField[num],
			\addToTail));*/
	});
	s.sync;

	~outputsAmount.do({
		arg num;
		var item = ~outputs[num];
		~hwOutputs.do({
			arg count;
			var name = 'hwOut' ++ count ++ 'sendSynth';
			var log;
			if(count == num) { item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~buses[\hwOut][count], \amp, 1], ~grpOutput[num], \addToTail)) }
			{ item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~buses[\hwOut][count], \amp, 0], ~grpOutput[num], \addToTail)) };
		});
	});
	s.sync;
};
~buses;
(
~vuSend = Routine {
	var value;
	loop {
		value  = ~buses[\input][0][\inCtrl].getSynchronous;
		value.postln;
		~myoscaddr.sendMsg('channel 1 value ' ++ value);
		0.5.wait;
	}
};
)
//~vuSend.play;
//~vuSend.stop;
//~vuSend.reset;
//OSCFunc.trace(false);