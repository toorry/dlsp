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
		arg busIn, busInCtrl, busOut, busOutCtrl,
		gain = 1.0;
		var sig;

		sig = In.ar( busIn, 1 );

		Out.kr( busInCtrl, sig );

		sig = sig * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\ambPan, {
		arg busIn, busOut, busOutCtrl,
		azimuth = 0,
		elevation = 0,
		radius = 1,
		distance = 1,
		mute = 1, volume = 1;
		var sig;

		sig = In.ar(busIn, 1);

		sig = HoaEncodeDirection.ar(sig, azimuth.degrad, elevation.degrad, radius, 1);
		sig = sig * volume * ~serverConf[\roomRadius] / distance;

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
		arg busIn, busOut, volume = 1;
		var sig;

		sig = In.ar( busIn, 1 );

		Out.ar( busOut, sig * volume );
	}).add;

	SynthDef(\ambSend, {
		arg busIn, busOut, volume = 1;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		Out.ar( busOut, sig * volume );
	}).add;
};