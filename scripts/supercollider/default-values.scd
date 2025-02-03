~initDefaultValues = {

	~defaultValues = Dictionary.new();

	~defaultValues.put(\inputs, 16);
	~defaultValues.put(\mixes, 8);
	~defaultValues.put(\points, 16);
	~defaultValues.put(\encoders, 4);
	~defaultValues.put(\fields, 4);
	~defaultValues.put(\spaces, 1);
	~defaultValues.put(\decoders, 1);
	~defaultValues.put(\outputs, 18);

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

	~defaultValues.put( \point, Dictionary.new());

	~defaultValues[\point].put( \gain, 1.0 );
	~defaultValues[\point].put( \X, 0 );
	~defaultValues[\point].put( \Y, ~serverConf[\roomRadius] );
	~defaultValues[\point].put( \Z, 0 );
	~defaultValues[\point].put( \azim, 0 );
	~defaultValues[\point].put( \elev, 0 );
	~defaultValues[\point].put( \dist, ~serverConf[\roomRadius] );
	~defaultValues[\point].put( \distMin, 0.1);
	~defaultValues[\point].put( \distMax, 1000);
	~defaultValues[\point].put( \mute, 0 );
	~defaultValues[\point].put( \volume, 1.0 );

	~defaultValues.put( \field, Dictionary.new());

	~defaultValues[\field].put( \gain, 1.0 );
	~defaultValues[\field].put( \reflect, "n" );
	~defaultValues[\field].put( \rotate, 0 );
	~defaultValues[\field].put( \tilt, 0 );
	~defaultValues[\field].put( \tumble, 0 );
	~defaultValues[\field].put( \zoom, Dictionary.new() );
	~defaultValues[\field][\zoom].put( \azim, 0 );
	~defaultValues[\field][\zoom].put( \elev, 0 );
	~defaultValues[\field][\zoom].put( \dist, 1 );
	~defaultValues[\field][\zoom].put( \angle, 0 );
	~defaultValues[\field].put( \mute, 1.0 );
	~defaultValues[\field].put( \volume, 1.0 );
};