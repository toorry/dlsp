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
		azim = 0,
		elev = 0,
		r = 1,
		dist = 1,
		mute = 1, volume = 1;
		var sig;

		sig = In.ar(busIn, 1);

		sig = HoaEncodeDirection.ar(sig, azim, elev, r, 1);
		sig = sig * volume * ~serverConf[\roomRadius] / dist;

		Out.ar(busOut, sig * mute);
		Out.kr(busOutCtrl, sig);
	}).add;

	SynthDef(\ambGain, {
		arg busIn, busInCtrl, busOut, busOutCtrl,
		gain = 1.0;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		Out.kr( busInCtrl, sig );

		sig = sig * gain;

		Out.ar( busOut, sig );
		Out.kr( busOutCtrl, sig );
	}).add;

	SynthDef(\ambTransform, {
		arg busIn, busOut, busOutCtrl, rotate = 0, tilt = 0, tumble = 0;
		var sig;

		sig = In.ar(busIn, ~serverConf[\ambChansAmount]);
		sig = HoaRTT.ar(sig, rotate, tilt, tumble, ~serverConf[\ambOrder]);

		Out.ar(busOut, sig);
		Out.kr(busOutCtrl, sig);
	}).add;

	SynthDef(\ambZoom, {
		arg busIn, busOut, busOutCtrl, angle = 0, azim = 0, elev = 0, dist = 1;
		var sig;

		sig = In.ar(busIn, ~serverConf[\ambChansAmount]);
		sig = HoaZoom.ar(sig, angle, azim, elev, dist, ~serverConf[\ambOrder]);

		Out.ar(busOut, sig);
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
		arg busIn, busOut, mute = 1, volume = 1;
		var sig;

		sig = In.ar( busIn, 1 );

		Out.ar( busOut, sig * mute * volume );
	}).add;

	SynthDef(\ambSend, {
		arg busIn, busOut ,mute = 1, volume = 1;
		var sig;

		sig = In.ar( busIn, ~serverConf[\ambChansAmount] );

		Out.ar( busOut, sig * mute * volume );
	}).add;

	SynthDef(\monoDelay, {
		arg busIn, busOut, delay = ~serverConf[\minDelayC];
		var sig, del;

		del = Lag.kr(delay, 0.5);
		sig = DelayL.ar( In.ar( busIn, 1 ), 10, del);

		Out.ar( busOut, sig );
	}).add;
};