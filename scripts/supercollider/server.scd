
~initConfig = Routine {

	"Declaring server environment".postln;
	~serverConf = Dictionary.new();
	~serverConf.put( \hwInputs, 2 );
	~serverConf.put( \hwOutputs, 2 );

	~serverConf.put( \inputsAmount, 36 );
	~serverConf.put( \mixesAmount, 12 );
	~serverConf.put( \pointsAmount, 24 );
	~serverConf.put( \fieldsAmount, 4 );
	~serverConf.put( \spacesAmount, 2 );
	~serverConf.put( \decodersAmount, 4 );
	~serverConf.put( \outputsAmount, 24 );

	~ambTransformerSlots;

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

	~vm;
	~vmRate;

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

	ambOrder = 3,
	hoaEncRadius = 1,
	hoaDirections = [45.0, 135.0, -135.0, -45.0].degrad,
	hoaBeamShape = \basic,
	hoaMatch = \amp,

	mainWindowWidth = 1024,
	mainWindowHeight = 768;

	"Setting server variables".postln;
	~hwInputs = hwInputs;
	~hwOutputs = hwOutputs;
	~inputsAmount = inputsAmount;
	~mixesAmount = mixesAmount;
	~pointsAmount = pointsAmount;
	~fieldsAmount = fieldsAmount;
	~spacesAmount = spacesAmount;
	~outputsAmount = outputsAmount;
	~decodersAmount = decodersAmount;

	~ambTransformerSlots = 4;

	~ambOrder = ambOrder;
	~hoaOrder = ~ambOrder;
	~ambChansAmount = (~ambOrder + 1).squared;
	~hoaEncRadius = hoaEncRadius;
	~hoaDirections = hoaDirections;
	~hoaBeamShape = hoaBeamShape;
	~hoaMatch = hoaMatch;

	~windowHeight = mainWindowHeight;
	~windowWidth = mainWindowWidth;

	~vmRate = 0.1;

	s.options.numInputBusChannels = ~hwInputs;
	s.options.numOutputBusChannels = ~hwOutputs;
	//s.options.inDevice = hwInDevice;
	//s.options.outDevice = hwOutDevice;
	s.options.sampleRate = hwSampleRate;
	s.options.memSize = memSize;
	s.waitForBoot({
		"Initializing kernels".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing kernels");
		~initKernels.value;
		s.sync();
		//1.0.wait;
		"Preparing Synth".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Preparing Synth");
		~prepareSynths.value;
		s.sync();
		//1.0.wait;
		"Initializing Busses".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Busses");
		~initBuses.value;
		s.sync();
		//1.0.wait;
		"Initializing Channels".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Channels");
		~initChannels.value;
		s.sync();
		//1.0.wait;
		"Initializing Groups".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Groups");
		~initGroups.value;
		s.sync();
		//1.0.wait;
		"Initializing Synths".postln;
		~ostagec.sendMsg("/dlsp/log", Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ "   Initializing Synths");
		~initSynths.value;
		s.sync();
		//1.0.wait;
		~initVM.value;
		s.sync();
		"Starting VolumeMeter".postln;
		~vmSend.play;
	});
};

~initKernels = {

	~ambEncBinaural = FoaEncoderMatrix.newHoa1;
	s.sync();
	~ambDecBinaural = FoaDecoderKernel.newCIPIC;
	s.sync();
};

~prepareSynths = {

	SynthDef(\inGain, {
		arg busIn, busOut, busOutCtrl, gain = 1.0;
		var sig;

		sig = In.ar( busIn, 1 ) * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\inGate, {
		arg busIn, busOut, busOutCtrl,
		threshold = 0.01, ratio = 10, attack = 0.01, release = 0.01, dryWet = 1.0;
		var sig;

		sig = In.ar(busIn, 1);
		sig = Compander.ar( in: sig, control: sig, thresh: threshold, slopeBelow: ratio, slopeAbove: 1.0,
			clampTime: attack, relaxTime: release ) * dryWet + sig * (1 - dryWet);

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\inEQ, {
		arg busIn, busOut, busOutCtrl,
		lowCutOn = 0, lowCutFreq = 100,
		lowShelfOn = 1, lowShelfFreq = 250, lowShelfQ = 1.0, lowShelfGain = 0,
		band1On = 1, band1Freq = 250, band1Q = 1.0, band1Gain = 0,
		band2On = 1, band2Freq = 600, band2Q = 1.0, band2Gain = 0,
		band3On = 1, band3Freq = 1500, band3Q = 1.0, band3Gain = 0,
		band4On = 1, band4Freq = 4000, band4Q = 1.0, band4Gain = 0,
		hiShelfOn = 1, hiShelfFreq = 4000, hiShelfQ = 1.0, hiShelfGain = 0,
		hiCutOn = 0, hiCutFreq = 10000,
		dryWet = 1.0;
		var sigIn, sigOut;

		sigIn = In.ar( busIn, 1 );
		sigOut = HPF.ar( in: sigIn, freq: lowCutFreq, mul: lowCutOn );
		sigOut = BLowShelf.ar( in: sigOut, freq: lowShelfFreq, rs: lowShelfQ, db: lowShelfGain, mul: lowShelfOn );
		sigOut = MidEQ.ar( in: sigOut, freq: band1Freq, rq: band1Q, db: band1Gain, mul: band1On );
		sigOut = MidEQ.ar( in: sigOut, freq: band2Freq, rq: band2Q, db: band2Gain, mul: band2On );
		sigOut = MidEQ.ar( in: sigOut, freq: band3Freq, rq: band3Q, db: band3Gain, mul: band3On );
		sigOut = MidEQ.ar( in: sigOut, freq: band4Freq, rq: band4Q, db: band4Gain, mul: band4On );
		sigOut = BHiShelf.ar( in: sigOut, freq: hiShelfFreq, rs: hiShelfQ, db: hiShelfGain, mul: hiShelfOn );
		sigOut = LPF.ar( in: sigOut, freq: hiCutFreq, mul: hiCutOn );
		sigOut = sigIn * (1 - dryWet) + sigOut * dryWet;

		Out.ar( busOut, sigOut );
		Out.kr( busOutCtrl, sigOut );
	}).add;

	SynthDef(\inDynEQ, {
		arg busIn, busOut, busOutCtrl, busCtrl1, busCtrl2,
		band1On = 1, band1Freq = 800, band1Q = 1.0, band1Treshold = 0.25, band1Attack = 0.1, band1Ratio = 1.0,
		band2On = 1, band2Freq = 800, band2Q = 1.0, band2Treshold = 0.25, band2Attack = 0.1, band2Ratio = 1.0,
		dryWet = 1.0;
		var sigIn, sigInCtrl, sigOut, sigCtrl1, sigCtrl2, sigEdit, band1db, band2db;

		sigIn = In.ar( busIn, 1 );
		sigInCtrl = In.kr( busIn, 1 );

		sigCtrl1 = BPF.kr( in: sigInCtrl, freq: band1Freq, rq: band1Q );
		sigCtrl2 = BPF.kr( in: sigInCtrl, freq: band2Freq, rq: band2Q );

		//trig1 = Amplitude.kr(sigInCtrl) > band1Treshold;

		band1db = Lag.kr( in: ( sigCtrl1.abs - band1Treshold) / band1Ratio, lagTime: band1Attack );
		band2db = Lag.kr( in: ( sigCtrl2.abs - band2Treshold) / band2Ratio, lagTime: band2Attack );

		sigOut = sigIn;
		sigEdit = MidEQ.ar( in: sigIn, freq: band1Freq, rq: band1Q, db: K2A.ar(band1db), mul: band1On );

		sigOut = Select.ar( sigCtrl1.abs > band1Treshold, [ sigEdit, sigOut ] );

		sigEdit = MidEQ.ar( in: sigOut, freq: band2Freq, rq: band2Q, db: K2A.ar(band2db), mul: band2On );

		sigOut = Select.ar( sigCtrl2.abs > band2Treshold, [ sigEdit, sigOut ]	);

		/*if(trig1, //
			{ band1db = Lag.kr( in: ( sigCtrl1.abs - band1Treshold) / band1Ratio, lagTime: band1Attack ); },
			{ band1db = 0; }
		);
		if(1 > 0, //sigCtrl2 > band2Treshold
			{ band2db = Lag.kr( in: ( sigCtrl2.abs - band2Treshold) / band2Ratio, lagTime: band2Attack ); },
			{ band2db = 0; };
		);

		sigOut = MidEQ.ar( in: sigIn, freq: band1Freq, rq: band1Q, db: band1db, mul: band1On );
		sigOut = MidEQ.ar( in: sigOut, freq: band2Freq, rq: band2Q, db: band2db, mul: band2On );*/
		sigOut = sigIn * (1 - dryWet) + sigOut * dryWet;

		Out.ar( busOut, sigOut );
		Out.kr( busOutCtrl, sigOut );
	}).add;

	SynthDef(\inComp, {
			arg busIn, busOut, busOutCtrl,
			threshold = 0.25, ratio = 3, attack = 0.01, release = 0.01, dryWet = 1.0;
			var sig;

			sig = In.ar( busIn, 1 );
			sig = Compander.ar( in: sig, control: sig, thresh: threshold, slopeBelow: 1.0, slopeAbove: 1 / ratio,
				clampTime: attack, relaxTime: release ) * dryWet + sig * (1 - dryWet);

			Out.ar( busOut, sig );
			Out.kr( busOutCtrl, sig );
		}).add;

	SynthDef(\inLimit, {
			arg busIn, busOut, busOutCtrl,
			threshold = 0.5, ratio = 1000, attack = 0.01, release = 0.01, dryWet = 1.0;
			var sig;

			sig = In.ar( busIn, 1 );
			sig = Compander.ar( in: sig, control: sig, thresh: threshold, slopeBelow: 1.0, slopeAbove: 1.0 / ratio,
				clampTime: attack, relaxTime: release ) * dryWet + sig * (1 - dryWet);

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

	SynthDef(\chanSend, {
			arg busIn, busOut, busOutCtrl, volume = 0.0, unmute = 1.0;
			var sig;

			sig = In.ar( busIn, 1 );

			Out.ar( busOut, sig * volume * unmute );
			Out.kr( busOut,sig * volume );
		}).add;

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for outVolume');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for ambPan');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for ambDecSpeakers');
	//s.sync();

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

};

~initBuses = {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~busSilent = Bus.audio(s,1);
	~busSilentCtrl = Bus.control(s, 1);
	~busTrash = Bus.audio(s,1);
	~busTrashCtrl = Bus.control(s, 1);
	//~ostagec.sendMsg('/dlsp/log', 'waiting for system buses');
	//s.sync();
	~buses = Dictionary();
	~buses.put(\hwIn,Array.newClear(~hwInputs));
	~buses.put(\hwOut,Array.newClear(~hwOutputs));
	~buses.put(\input,Array.newClear(~inputsAmount));
	~buses.put(\mix,Array.newClear(~mixesAmount));
	~buses.put(\point,Array.newClear(~pointsAmount));
	~buses.put(\field,Array.newClear(~fieldsAmount));
	~buses.put(\space, Array.newClear(~spacesAmount));
	~buses.put(\decoder, Array.newClear(~decodersAmount));
	~buses.put(\output, Array.newClear(~outputsAmount));
	//~ostagec.sendMsg('/dlsp/log', 'waiting for buses dictionary');
	//s.sync();

	~hwInputs.do ({
		arg num;
		~buses[\hwIn][num] = Dictionary.new();
		~buses[\hwIn][num].put(\in, ~hwOutputs + num);
		~buses[\hwIn][num].put(\inCtrl, Bus.control(s, 1));
		~buses[\hwIn][num].put(\out, Bus.audio(s, 1));
		~buses[\hwIn][num].put(\outCtrl, Bus.control(s, 1));
	});
	~buses[\hwIn].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for hwInputs buses');
	//s.sync();

	~hwOutputs.do ({
		arg num;
		~buses[\hwOut][num] = Dictionary.new();
		~buses[\hwOut][num].put(\in, Bus.audio(s, 1));
		~buses[\hwOut][num].put(\inCtrl, Bus.control(s, 1));
		~buses[\hwOut][num].put(\out, num);
		~buses[\hwOut][num].put(\outCtrl, Bus.control(s, 1));
	});
	~buses[\hwOut].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for hwOutputs buses');
	//s.sync();
	~inputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\gain,Bus.audio(s,1));
		item.put(\gainCtrl, Bus.control(s, 1));
		item.put(\gate,Bus.audio(s,1));
		item.put(\gateCtrl, Bus.control(s, 1));
		item.put(\eq,Bus.audio(s,1));
		item.put(\eqCtrl, Bus.control(s, 1));
		item.put(\dynEQ,Bus.audio(s,1));
		item.put(\dynEQCtrl, Bus.control(s, 1));
		item.put(\dynEQCtrl1, Bus.control(s, 1));
		item.put(\dynEQCtrl2, Bus.control(s, 1));
		item.put(\comp,Bus.audio(s,1));
		item.put(\compCtrl, Bus.control(s, 1));
		item.put(\ins,Bus.audio(s,1));
		item.put(\insCtrl, Bus.control(s, 1));
		item.put(\limit,Bus.audio(s,1));
		item.put(\limitCtrl, Bus.control(s, 1));
		item.put(\outPre,Bus.audio(s,1));
		item.put(\outPreCtrl, Bus.control(s, 1));
		item.put(\out,Bus.audio(s,1));
		item.put(\outCtrl, Bus.control(s, 1));
		item.put(\mixSendCtrl, Array.new(~mixesAmount));
		item[\mixSendCtrl].do ({ arg item = Bus.control(s, 1); });
		item.put(\pointSendCtrl, Array.new(~pointsAmount));
		item[\pointSendCtrl].do ({ arg item = Bus.control(s, 1); });
		item.put(\outSendCtrl, Array.new(~outputsAmount));
		item[\outSendCtrl].do ({ arg item = Bus.control(s, 1); });
		~buses[\input][num]=item;
	});
	~buses[\input].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Inputs buses');
	//s.sync();
	~mixesAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\eq,Bus.audio(s,1));
		item.put(\eqCtrl, Bus.control(s, 1));
		item.put(\dynEQ,Bus.audio(s,1));
		item.put(\dynEQCtrl, Bus.control(s, 1));
		item.put(\dynEQCtrl1, Bus.control(s, 1));
		item.put(\dynEQCtrl2, Bus.control(s, 1));
		item.put(\comp,Bus.audio(s,1));
		item.put(\compCtrl, Bus.control(s, 1));
		item.put(\ins,Bus.audio(s,1));
		item.put(\insCtrl, Bus.control(s, 1));
		item.put(\limit,Bus.audio(s,1));
		item.put(\limitCtrl, Bus.control(s, 1));
		item.put(\outPre,Bus.audio(s,1));
		item.put(\outPreCtrl, Bus.control(s, 1));
		item.put(\out,Bus.audio(s,1));
		item.put(\outCtrl, Bus.control(s, 1));
		item.put(\pointSendCtrl, Array.new(~pointsAmount));
		item[\pointSendCtrl].do ({ arg item = Bus.control(s, 1); });
		item.put(\outSendCtrl, Array.new(~outputsAmount));
		item[\outSendCtrl].do ({ arg item = Bus.control(s, 1); });
		~buses[\mix][num]=item;
	});
	~buses[\mix].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Mixes buses');
	//s.sync();
	~pointsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		item.put(\inCtrl, Bus.control(s, 1));
		item.put(\out,Bus.audio(s,1));
		item.put(\outCtrl, Bus.control(s, 1));
		item.put(\fieldPan, Array.new(~fieldsAmount));
		item[\fieldPan].do ({ arg item = Bus.audio(s, ~ambChansAmount); });
		item.put(\fieldPanCtrl, Array.new(~fieldsAmount));
		item[\fieldPanCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\spacePan, Array.new(~spacesAmount));
		item[\spacePan].do ({ arg item = Bus.audio(s, ~ambChansAmount); });
		item.put(\spacePanCtrl, Array.new(~spacesAmount));
		item[\spacePanCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\outSendCtrl, Array.new(~outputsAmount));
		item[\outSendCtrl].do ({ arg item = Bus.control(s, 1); });
		~buses[\point][num]=item;
	});
	~buses[\point].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Points buses');
	//s.sync();
	~fieldsAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\slot, Array.new(~ambTransformerSlots));
		item[\slot].do ({ arg item = Bus.audio(s, ~ambChansAmount); });
		item.put(\slotCtrl, Array.new(~ambTransformerSlots));
		item[\slotCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\out,Bus.audio(s,~ambChansAmount));
		item.put(\outCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\spaceSendCtrl, Array.new(~spacesAmount));
		item[\spaceSendCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\decSendCtrl, Array.new(~decodersAmount));
		item[\decSendCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\outSendCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\field][num] = item;
	});
	~buses[\field].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Fields buses');
	//s.sync();
	~spacesAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\slot, Array.new(~ambTransformerSlots));
		item[\slot].do ({ arg item = Bus.audio(s, ~ambChansAmount); });
		item.put(\slotCtrl, Array.new(~ambTransformerSlots));
		item[\slotCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\out,Bus.audio(s,~ambChansAmount));
		item.put(\outCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\decSendCtrl, Array.new(~decodersAmount));
		item[\decSendCtrl].do ({ arg item = Bus.control(s, ~ambChansAmount); });
		item.put(\outSendCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\space][num] = item;
	});
	~buses[\space].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Spaces buses');
	//s.sync();
	~decodersAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		item.put(\inCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\nfc,Bus.audio(s,~ambChansAmount));
		item.put(\nfcCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\out,Bus.audio(s,~ambChansAmount));
		item.put(\outCtrl, Bus.control(s, ~ambChansAmount));
		item.put(\outSendCtrl, Bus.control(s, ~ambChansAmount));
		~buses[\decoder][num] = item;
	});
	~buses[\space].postln;

	~buses.put(\outputs, Bus.audio(s, ~outputsAmount));
	~buses.put(\outputsCtrl, Bus.control(s, ~outputsAmount));
	~outputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.newFrom(~buses[\outputs], num, 1));
		item.put(\inCtrl, Bus.newFrom(~buses[\outputsCtrl], num, 1));
		item.put(\out,Bus.audio(s, 1));
		item.put(\outCtrl, Bus.control(s, 1));
		item.put(\hwOutSendCtrl, Array.new(~outputsAmount));
		item[\hwOutSendCtrl].do ({ arg item = Bus.control(s, 1); });
		~buses[\output][num]=item;
	});
	~buses[\output].postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Outputs buses');
	//s.sync();
};

~initChannels = {

	//Initialise INPUTS
	~inputs = Array.newClear(~inputsAmount);
	~inputsAmount.do({
		arg num;
		var input = Dictionary();
		input.put(\busIn, ~buses[\input][num][\in]);
		input.put(\busInCtrl, ~buses[\input][num][\inCtrl]);
		input.put(\busGain, ~buses[\input][num][\gain]);
		input.put(\busGainCtrl, ~buses[\input][num][\gainCtrl]);
		input.put(\busGate, ~buses[\input][num][\gate]);
		input.put(\busGateCtrl, ~buses[\input][num][\gateCtrl]);
		input.put(\busEQ, ~buses[\input][num][\eq]);
		input.put(\busEQCtrl, ~buses[\input][num][\eqCtrl]);
		input.put(\busDynEQ, ~buses[\input][num][\dynEQ]);
		input.put(\busDynEQCtrl, ~buses[\input][num][\dynEQCtrl]);
		input.put(\busDynEQCtrl1, ~buses[\input][num][\dynEQCtrl1]);
		input.put(\busDynEQCtrl2, ~buses[\input][num][\dynEQCtrl2]);
		input.put(\busComp, ~buses[\input][num][\comp]);
		input.put(\busCompCtrl, ~buses[\input][num][\compCtrl]);
		input.put(\busIns, ~buses[\input][num][\ins]);
		input.put(\busInsLimit, ~buses[\input][num][\insCtrl]);
		input.put(\busLimit, ~buses[\input][num][\limit]);
		input.put(\busLimitCtrl, ~buses[\input][num][\limit]);
		input.put(\busOutPre, ~buses[\input][num][\outPre]);
		input.put(\busOutPreCtrl, ~buses[\input][num][\outPreCtrl]);
		input.put(\busOut, ~buses[\input][num][\out]);
		input.put(\busOutCtrl, ~buses[\input][num][\outCtrl]);
		~inputs[num] = input;
	});
	~inputs.postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Inputs dictionary');
	//s.sync();

	//Initialise MIXES
	~mixes = Array.newClear(~mixesAmount);
	~mixesAmount.do({
		arg num;
		var mix = Dictionary();
		mix.put(\busIn, ~buses[\mix][num][\in]);
		~mixes[num] = mix;
	});
	~mixes.postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Mixes dictionary');
	//s.sync();

	//Initialise POINTS
	~points = Array.newClear(~pointsAmount);
	~pointsAmount.do({
		arg num;
		var point = Dictionary();
		point.put(\bus, ~buses[\point][num]);
		~points[num] = point;
	});
	~points.postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Points dictionary');
	//s.sync();

	~fields = Array.newClear(~fieldsAmount);
	~fieldsAmount.do({
		arg num;
		var field = Dictionary();
		field.put(\bus, ~buses[\field][num]);
		~fields[num] = field;
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Fields dictionary');
	//s.sync();

	~spaces = Array.newClear(~spacesAmount);
	~spacesAmount.do({
		arg num;
		var space = Dictionary();
		space.put(\bus, ~buses[\space][num]);
		~spaces[num] = space;
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Spaces dictionary');
	//s.sync();

	~decoders = Array.newClear(~decodersAmount);
	~decodersAmount.do({
		arg num;
		var decoder = Dictionary();
		decoder.put(\bus, ~buses[\decoder][num]);
		~decoders[num] = decoder;
	});

	//Initialise OUTPUTS
	~outputs = Array.newClear(~outputsAmount);
	~outputsAmount.do({
		arg num;
		var output = Dictionary();
		output.put(\bus, ~buses[\output][num]);
		~outputs[num] = output;
	});
	~outputs.postln;
	//~ostagec.sendMsg('/dlsp/log', 'waiting for Outputs dictionary');
	//s.sync();
};

//Initialise GROUPS

~initGroups = {

	~grpHwInputs = Group.new;
	~grpSources = Group.after(~grpHwInputs);
	~grpInputs = Group.after(~grpSources);
	~grpMixes = Group.after(~grpInputs);
	~grpPoints = Group.after(~grpMixes);
	~grpFields = Group.after(~grpPoints);
	~grpSpaces = Group.after(~grpFields);
	~grpOutputs = Group.after(~grpSpaces);
	~grpHwOutputs = Group.after(~grpInputs);
	//~ostagec.sendMsg('/dlsp/log', 'waiting for main groups');
	//s.sync();
	~grpInput = Array.newClear(~inputsAmount);
	~grpMix = Array.newClear(~mixesAmount);
	~grpPoint = Array.newClear(~pointsAmount);
	~grpField = Array.newClear(~fieldsAmount);
	~grpSpace = Array.newClear(~spacesAmount);
	~grpOutput = Array.newClear(~outputsAmount);
	//~ostagec.sendMsg('/dlsp/log', 'waiting for channel groups');
	//s.sync();
	~inputsAmount.do({
		arg num;
		~grpInput[num] = Group.new(~grpInputs, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for inputs group adds');
	//s.sync();
	~mixesAmount.do({
		arg num;
		~grpMix[num] = Group.new(~grpMixes, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for mixes group adds');
	//s.sync();
	~pointsAmount.do({
		arg num;
		~grpPoint[num] = Group.new(~grpPoints, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for points group adds');
	//s.sync();
	~fieldsAmount.do({
		arg num;
		~grpField[num] = Group.new(~grpFields, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for fields group adds');
	//s.sync();
	~spacesAmount.do({
		arg num;
		~grpSpace[num] = Group.new(~grpSpaces, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for spaces group adds');
	//s.sync();
	~outputsAmount.do({
		arg num;
		~grpOutput[num] = Group.new(~grpOutputs, \addToTail);
	});
	//~ostagec.sendMsg('/dlsp/log', 'waiting for outputs group adds');
	//s.sync();
};

//Initialise SYNTHS

~initSynths = {

	~inputsAmount.do({
		arg num;
		var item = ~inputs[num];

		item.put('synthGain', Synth(\inGain,
			[\busIn, item[\busIn],
				\busOut, item[\busGain],
				\busOutCtrl, item[\busGainCtrl]
			],
			~grpInput[num],
			\addToTail)
		);
		item.put('synthGate', Synth(\inGate,
			[\busIn, item[\busGain],
				\busOut, item[\busGate],
				\busOutCtrl, item[\busGateCtrl],
			],
			~grpInput[num],
			\addToTail)
		);
		item.put('synthEQ', Synth(\inEQ,
			[\busIn, item[\busGate],
				\busOut, item[\busEQ],
				\busOutCtrl, item[\busEQCtrl]
			],
			~grpInput[num],
			\addToTail)
		);
		item.put('synthDynEQ', Synth(\inDynEQ,
			[\busIn, item[\busEQ],
				\busOut, item[\busDynEQ],
				\busOutCtrl, item[\busDynEQCtrl],
				\busCtrl1, item[\busDynEQCtrl1],
				\busCtrl2, item[\busDynEQCtrl2]
			],
			~grpInput[num],
			\addToTail)
		);
		item.put('synthComp', Synth(\inComp,
			[\busIn, item[\busDynEQ],
				\busOut, item[\busComp],
				\busOutCtrl, item[\busCompCtrl]
			],
			~grpInput[num],
			\addToTail)
		);
		item.put('synthLimit', Synth(\inLimit,
			[\busIn, item[\busComp],
				\busOut, item[\busLimit],
				\busOutCtrl, item[\busLimitCtrl]
			],
			~grpInput[num],
			\addToTail)
		);

		item.put('synthOut', Synth(\chanOut,
			[\busIn, item[\busLimit],
				\busOutPre, item[\busOutPre],
				\busOutPreCtrl, item[\busOutPreCtrl],
				\busOut, item[\busOut],
				\busOutCtrl, item[\busOutCtrl]
			],
			~grpInput[num],
			\addToTail)
		);

		~mixesAmount.do({
			arg count;

			item.put('synthSendPreMix' ++ count, Synth(\chanSend,
				[\busIn, item[\busOutPre],
					\busOut, ~mixes[count][\busIn],
					\busOutCtrl, ~mixes[count][\busInCtrl]
				],
				~grpInput[num],
				\addToTail)
			);
			item.put('synthSendMix' ++ count, Synth(\chanSend,
				[\busIn, item[\busOut],
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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for input synths');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for mixes synths');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for points synths');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for fields synths');
	//s.sync();

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
	//~ostagec.sendMsg('/dlsp/log', 'waiting for outputs synths');
	//s.sync();
};

~initVM = {
	~vm = Dictionary.new();
	~vm.put(\hwIn, Dictionary.new()); //hwIn
	~vm.put(\sources, Dictionary.new()); //Sources
	~vm.put(\inputs, Dictionary.new());  //Inputs
	~vm.put(\mixes, Dictionary.new()); //Mixes
	~vm.put(\points, Dictionary.new()); //Points
	~vm.put(\fields, Dictionary.new()); //Fields
	~vm.put(\spaces, Dictionary.new()); //Spaces
	~vm.put(\decoders, Dictionary.new()); //Decoders
	~vm.put(\outputs, Dictionary.new()); //Outputs
	~vm.put(\hwOut, Dictionary.new()); //hwOut

	~vm[\inputs].put(\in, List.newClear());
	~vm[\inputs].put(\gain, List.newClear());
	~vm[\inputs].put(\gate, List.newClear());
	~vm[\inputs].put(\eq, List.newClear());
	~vm[\inputs].put(\comp, List.newClear());
	~vm[\inputs].put(\ins, List.newClear());
	~vm[\inputs].put(\limit, List.newClear());
	~vm[\inputs].put(\outPre, List.newClear());
	~vm[\inputs].put(\out, List.newClear());
	~vm[\inputs].put(\mixSendsPre, List.newClear());
	~vm[\inputs].put(\mixSends, List.newClear());
	~vm[\inputs].put(\pointSendsPre, List.newClear());
	~vm[\inputs].put(\pointSends, List.newClear());
	~vm[\inputs].put(\outSendsPre, List.newClear());
	~vm[\inputs].put(\outSends, List.newClear());

	~vm.postln;

	~vm[\inputs][\in].add(1);
	~vm[\inputs][\in].add(2);
	~vm[\inputs][\in].add(3);
	~vm[\inputs][\in].add(4);
};

~vmSend = Routine {
	var value;
	loop {
		"vm".postln;
		~vm.keys.do ({
			arg chanType;
			//(' '++chanType).postln;
			~vm[chanType].keys.do ({
				arg busType;
				//('  '++busType).postln;
				~vm[chanType][busType].do ({
					arg value;
					(value + " ").post;
					switch (busType,
						\in, {
							~ostagec.sendMsg("/v", "i", "in", value, ~buses[\input][value-1][\inCtrl].getSynchronous.abs.postln); //getSynchronous.abs
						},
						\mixSends, {
							value.do ({
								//
							});
						},
					);
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