////FIRST RUN INSTALLS

//Installed GIT required.
Quarks.gui;
AmbiVerbGUI(s);

//Ambisonic ToolKit
Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");

Atk.downloadKernels;
Atk.downloadMatrices;
Atk.downloadSounds;

Atk.userKernelDir.postln;
Atk.userMatrixDir.postln;
Atk.userSoundsDir.postln;

//Ambisonic Decoder Toolbox
Quarks.install("https://gitlab.com/dxarts/projects/adt.quark");

ADT.userOctaveCmd = "C:\Users\timmy\adt"

//AmbiVerbSC
Quarks.install("https://github.com/JamesWenlock/AmbiVerbSC");

ServerOptions.inDevices.do({
	arg item;
	item.postln;
});
ServerOptions.outDevices.do({
	arg item;
	item.postln;
});


Server.killAll;
s.quit;

////REGULAR RUN

~initConfig.value;
~bootConfig.value(
	hwInputs: 2, hwOutputs: 2,
	//hwInDevice: "Windows WASAPI : Microphone Array (AMD Audio Device)",
	hwInDevice: "Windows WASAPI : CABLE Output (VB-Audio Virtual Cable)",
	hwOutDevice: "Windows WASAPI : Line (Realphones System-Wide)",
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
~initKernels.value;
~prepareSynths.value;
~initBuses.value;
~initChannels.value;
~initGroups.value;
~initSynths.value;
~initMainWindow.value;

~wdw.front;

s.quit;

// SETTINGS

~initConfig = {

	~hwInputs;
	~hwOutputs;

	~inputsAmount;
	~mixesAmount;
	~pointsAmount;
	~fieldsAmount;
	~spacesAmount;
	~outputsAmount;

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


};

//START
//s.options.device = "ASIO : Soundcraft USB Audio ASIO";
//s.options.inDevice = "Windows WASAPI : Microphone (Realtek(R) Audio)";
//s.options.inDevice = "Windows WASAPI : Microphone (Realtek High Definition Audio)";
s.options.inDevice = "Windows WASAPI : CABLE Output (VB-Audio Virtual Cable)";
s.options.outDevice = "Windows WASAPI : Line (Realphones System-Wide)";
//s.options.outDevice = "ASIO : Soundcraft USB Audio ASIO";
//s.options.hardwareBufferSize = 256;
//s.options.hardwareBufferSize;
s.options.sampleRate = 48000;
s.options.numInputBusChannels = ~hwInputs;
s.options.numOutputBusChannels = ~hwOutputs;
//s.options.numInputBusChannels;
//s.options.numOutputBusChannels;
s.options.memSize = 1048576; //1048576KB = 1GB
s.boot;

~bootConfig = {
	arg hwInputs = 2, hwOutputs = 2,
	hwInDevice = "Windows WASAPI : Microphone Array (AMD Audio Device)",
	hwOutDevice = "Windows WASAPI : Line (Realphones System-Wide)",
	hwSampleRate = 48000,

	memSize = 1048576,

	inputsAmount = 4,
	mixesAmount = 4,
	pointsAmount = 4,
	fieldsAmount = 1,
	spacesAmount = 1,
	outputsAmount = 4,

	ambOrder = 3,
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
	s.options.inDevice = hwInDevice;
	s.options.outDevice = hwOutDevice;
	s.options.sampleRate = hwSampleRate;
	s.options.memSize = memSize;
	s.boot;
};

~initKernels = {

	~ambEncBinaural = FoaEncoderMatrix.newHoa1;
	~ambDecBinaural = FoaDecoderKernel.newCIPIC;
};

~netSend = NetAddr.new("127.0.0.1",7799);
~netRecv = NetAddr.new("127.0.0.1",7797);

//Prepare SYNTHs

~prepareSynths = {

	SynthDef(\outVolume, {
		arg busIn, busOut, channels = 1, amp = 0;
		Out.ar(busOut, In.ar(busIn,channels) * amp);
	}).add;

	SynthDef(\ambPan, {
		arg busIn, busOut, amp=0, angRot = 0, angElev = 0, omni = 0;
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
	}).add;

	SynthDef(\ambDecSpeakers, {
		arg busIn, busOut, amp=0;
		var sndIn;

		sndIn = In.ar(busIn,~ambChansAmount);

		sndIn = HoaDecodeMatrix.ar(sndIn, HoaMatrixDecoder.newModeMatch(
		~hoaDirections,
		beamShape: ~hoaBeamShape,
		match: ~hoaMatch,
		order: ~hoaOrder));

		Out.ar(busOut, sndIn);
	}).add;

	SynthDef(\ambDecBinaural, {
		arg busIn, busOut, amp=0;
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
	}).add;
};

//Initialise BUSES

~initBuses = {

	~hwInputs = s.options.numInputBusChannels;
	~hwOutputs = s.options.numOutputBusChannels;

	~busSilent = Bus.audio(s,1);
	~busTrash = Bus.audio(s,1);

	~buses = Dictionary();
	~buses.put(\hwIn,Array.newClear(~hwInputs));
	~buses.put(\hwOut,Array.newClear(~hwOutputs));
	~buses.put(\input,Array.newClear(~inputsAmount));
	~buses.put(\mix,Array.newClear(~mixesAmount));
	~buses.put(\point,Array.newClear(~pointsAmount));
	~buses.put(\field,Array.newClear(~fieldsAmount));
	~buses.put(\space, Array.newClear(~spacesAmount));
	~buses.put(\output, Array.newClear(~outputsAmount));

	~hwInputs.do ({
		arg num;
		~buses[\hwIn][num] = ~hwOutputs + num;
	});
	~buses[\hwIn].postln;

	~hwOutputs.do ({
		arg num;
		~buses[\hwOut][num] = num;
	});
	~buses[\hwOut].postln;

	~inputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		~buses[\input][num]=item;
	});
	~buses[\input].postln;

	~mixesAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		~buses[\mix][num]=item;
	});
	~buses[\mix].postln;

	~pointsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,1));
		~buses[\point][num]=item;
	});
	~buses[\point].postln;

	~fieldsAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		~buses[\field][num] = item;
	});
	~buses[\field].postln;

	~spacesAmount.do({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.audio(s,~ambChansAmount));
		~buses[\space][num] = item;
	});
	~buses[\space].postln;

	~buses.put(\outputs, Bus.audio(s, ~outputsAmount));
	~outputsAmount.do ({
		arg num;
		var item = Dictionary();
		item.put(\in,Bus.newFrom(~buses[\outputs], num, 1));
		~buses[\output][num]=item;
	});
	~buses[\output].postln;
};

~initChannels = {

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

	//Initialise MIXES
	~mixes = Array.newClear(~mixesAmount);
	~mixesAmount.do({
		arg num;
		var mix = Dictionary();
		mix.put(\busIn,~buses[\mix][num][\in]);
		//input.put(\outVolume,Bus(audio(s,1)));
		~mixes[num] = mix;
	});
	~mixes.postln;

	//Initialise POINTS
	~points = Array.newClear(~pointsAmount);
	~pointsAmount.do({
		arg num;
		var point = Dictionary();
		point.put(\busIn,~buses[\point][num][\in]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~points[num] = point;
	});
	~points.postln;

	//Initialise OUTPUTS
	~outputs = Array.newClear(~outputsAmount);
	~outputsAmount.do({
		arg num;
		var output = Dictionary();
		output.put(\busIn,~buses[\output][num][\in]);
		//point.put(\outVolume,Bus(audio(s,1)));
		~outputs[num] = output;
	});
	~outputs.postln;
};

//Initialise GROUPS

~initGroups = {

	~grpHwInputs = Group.new;
	~grpInputs = Group.after(~grpHwInputs);
	~grpMixes = Group.after(~grpInputs);
	~grpPoints = Group.after(~grpMixes);
	~grpFields = Group.after(~grpPoints);
	~grpSpaces = Group.after(~grpFields);
	~grpOutputs = Group.after(~grpSpaces);
	~grpHwOutputs = Group.after(~grpInputs);

	~grpInput = Array.newClear(~inputsAmount);
	~grpMix = Array.newClear(~mixesAmount);
	~grpPoint = Array.newClear(~pointsAmount);
	~grpField = Array.newClear(~fieldsAmount);
	~grpSpace = Array.newClear(~spacesAmount);
	~grpOutput = Array.newClear(~outputsAmount);

	~inputsAmount.do({
		arg num;
		~grpInput[num] = Group.new(~grpInputs, \addToTail);
	});
	~mixesAmount.do({
		arg num;
		~grpMix[num] = Group.new(~grpMixes, \addToTail);
	});
	~pointsAmount.do({
		arg num;
		~grpPoint[num] = Group.new(~grpPoints, \addToTail);
	});
	~fieldsAmount.do({
		arg num;
		~grpField[num] = Group.new(~grpFields, \addToTail);
	});
	~spacesAmount.do({
		arg num;
		~grpSpace[num] = Group.new(~grpSpaces, \addToTail);
	});
	~outputsAmount.do({
		arg num;
		~grpOutput[num] = Group.new(~grpOutputs, \addToTail);
	});
};

//Initialise SYNTHS

~initSynths = {

	~inputsAmount.do({
		arg num;
		var item = ~inputs[num];
		~mixesAmount.do({
			arg count;
			var name = 'mix' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~mixes[count][\busIn]], ~grpInput[num], \addToTail));
		});
		~pointsAmount.do({
			arg count;
			var name = 'point' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[count][\busIn]], ~grpInput[num], \addToTail));
		});
	});

	~mixesAmount.do({
		arg num;
		var item = ~mixes[num];
		~pointsAmount.do({
			arg count;
			var name = 'point' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[count][\busIn]], ~grpMix[num], \addToTail));
		});
	});

	~pointsAmount.do({
		arg num;
		var item = ~points[num];
		~outputsAmount.do({
			arg count;
			var name = 'output' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~buses[\output][count][\in]], ~grpPoint[num], \addToTail));
		});
		~fieldsAmount.do({
			arg count;
			var name = 'field' ++ count ++ 'ambPanSynth';
			item.put(name, Synth(\ambPan, [\busIn, item.at(\busIn), \busOut, ~buses[\field][count][\in]], ~grpPoint[num], \addToTail));
		});
	});

	~fieldsAmount.do({
		arg num;
		var item = ~fields[num];
		~spacesAmount.do({
			arg count;
			var name = 'space' ++ count ++ 'sendSynth';
			item.put(name, Synth(\outVolume,
				[\busIn, item[\busIn],
				\busOut, ~buses[\space][count][\in],
				\channels, ~ambChansAmount],
				~grpField[num], \addToTail));
		});
		item.put(\outputsSend, Synth(\outVolume,
			[\busIn, item[\busIn],
			\busOut, ~buses[\output][0][\in],
			\channels, ~ambChansAmount],
			~grpField[num],
			\addToTail));
	});

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
};

//HOA Case





~atkSynth = Synth(\sndPan,[\busIn,4,\busOut,0]);

~wAtk = Window.new('atkPan', Rect(
	Window.screenBounds.width/2-400,
	Window.screenBounds.height/2-300,
	800,
	600));

~sldVol = Slider.new(~wAtk.view, Rect.new(
		100,
		100,
		400,
	100));
	~sldVol.action_({
		arg obj;
	var amp = obj.value * 4;
		~atkSynth.set(\amp,amp);
	});
~sldRot = Slider.new(~wAtk.view, Rect.new(
		100,
		220,
		400,
	100));
	~sldRot.action_({
		arg obj;
	var angle = (obj.value*2 - 1) * pi;
	~atkSynth.set(\angRot,angle);
	});
~sldElev = Slider.new(~wAtk.view, Rect.new(
		100,
		340,
		400,
	100));
	~sldElev.action_({
		arg obj;
	var angle = (obj.value * 2 - 1) * pi / 2;
	~atkSynth.set(\angElev,angle);
	});
~sldRad = Slider.new(~wAtk.view, Rect.new(
		100,
		460,
		400,
	100));
	~sldRad.action_({
		arg obj;
	var omni = obj.value;
	~atkSynth.set(\omni,omni);
	});


~wAtk.front;

//Initialise GUI

~initMainWindow = {

	~guis = Dictionary();
	~guis.put(\mixer, Dictionary());
	~guis[\mixer].put(\layouts,Dictionary());
	~guis[\mixer][\layouts].put(\main,VLayout.new());
	~guis[\mixer][\layouts].put(\inputs,HLayout.new());
	~guis[\mixer][\layouts].put(\mixes,HLayout.new());
	~guis[\mixer][\layouts].put(\points,HLayout.new());
	~guis[\mixer].put(\inputs,Array.newClear(~inputsAmount));
	~guis[\mixer].put(\mixes,Array.newClear(~mixesAmount));
	~guis[\mixer].put(\points,Array.newClear(~pointsAmount));

	~inputsAmount.do({
		arg num;
		var item = Dictionary ();
		item.put(\layouts, Dictionary());
		item[\layouts].put(\main, VLayout.new());
		item[\layouts].put(\mixSends, VLayout.new());
		item[\layouts].put(\pointSends, VLayout.new());
		item.put(\mixSends,Array.newClear(~mixesAmount));
		item.put(\pointSends,Array.newClear(~pointsAmount));
		~mixesAmount.do({
			arg count;
			var item2 = Dictionary();
			item2.put(\layout,HLayout.new());
			item[\mixSends][count] = item2;
		});
		~pointsAmount.do({
			arg count;
			var item2 = Dictionary();
			item2.put(\layout,HLayout.new());
			item[\pointSends][count] = item2;
		});
		~guis[\mixer][\inputs][num] = item;
	});

	~mixesAmount.do({
		arg num;
		var item = Dictionary ();
		item.put(\layouts, Dictionary());
		item[\layouts].put(\main, VLayout.new());
		item[\layouts].put(\pointSends, VLayout.new());
		item.put(\pointSends,Array.newClear(~pointsAmount));
		~pointsAmount.do({
			arg count;
			var item2 = Dictionary();
			item2.put(\layout,HLayout.new());
			item[\pointSends][count] = item2;
		});
		~guis[\mixer][\mixes][num] = item;
	});

	~pointsAmount.do({
		arg num;
		var item = Dictionary ();
		item.put(\layouts, Dictionary());
		item[\layouts].put(\main, VLayout.new());
		item[\layouts].put(\outputSends,VLayout.new());
		item.put(\outputSends,Array.newClear(~outputsAmount));
		~outputsAmount.do({
			arg count;
			var item2 = Dictionary();
			item2.put(\layout, HLayout.new());
			item[\outputSends][count] = item2;
		});
		~guis[\mixer][\points][num] = item;
	});

	~wdw = Window.new('mixer', Rect(
		(Window.screenBounds.width / 2) - (~windowHeight / 2),
		(Window.screenBounds.height / 2) - (~windowWidth / 2),
		~windowWidth,
		~windowHeight));

	~viewMain = TabbedView2.new(~wdw);
	//~viewMain.tabHeight;
	~viewMain.tabHeight_(20);
	~viewMain.resize = 5;
	~tabMixer = ~viewMain.add(\Mixer,scroll:false).closable_(false);
	~tabInputs = ~viewMain.add(\Inputs,scroll:false).closable_(false);
	~tabMixes = ~viewMain.add(\Mixes,scroll:false).closable_(false);
	~tabPoints = ~viewMain.add(\Points,scroll:false).closable_(false);
	~tabFields = ~viewMain.add(\Fields,scroll:false).closable_(false);
	~tabSpaces = ~viewMain.add(\Spaces,scroll:false).closable_(false);

	~viewInputs = TabbedView2.new(~tabInputs);
	~viewMixes = TabbedView2.new(~tabMixes);
	~viewPoints = TabbedView2.new(~tabPoints);
	~viewFields = TabbedView2.new(~tabFields);
	~viewSpaces = TabbedView2.new(~tabSpaces);

	~inputsAmount.do({
		arg num;
		~viewInputs.add('Input ' ++ (num + 1), scroll:false).closable_(false);
	});

	~mixesAmount.do({
		arg num;
		~viewMixes.add('Mix ' ++ (num + 1), scroll:false).closable_(false);
	});

	~pointsAmount.do({
		arg num;
		~viewPoints.add('Point ' ++ (num + 1), scroll:false).closable_(false);
	});

	~fieldsAmount.do({
		arg num;
		~viewFields.add('Field ' ++ (num + 1), scroll:false).closable_(false);
	});

	~spacesAmount.do({
		arg num;
		~viewSpaces.add('Space ' ++ (num + 1), scroll:false).closable_(false);
	});

	//MIXER Tab
	~tabMixer.layout = ~guis[\mixer][\layouts][\main];
	~guis[\mixer][\layouts][\main].add(~guis[\mixer][\layouts][\inputs], stretch:0, align:\center);
	~guis[\mixer][\layouts][\main].add(~guis[\mixer][\layouts][\mixes], stretch:0, align:\center);
	~guis[\mixer][\layouts][\main].add(~guis[\mixer][\layouts][\points], stretch:0, align:\center);

	//LineLayout
	~inputsAmount.do({
		arg num;
		var label = StaticText.new(~tabMixer),
		lblMixSends = StaticText.new(~tabMixer),
		lblPointSends = StaticText.new(~tabMixer),
		wH = ~windowHeight - ~viewMain.tabHeight,
		wW = ~windowWidth,
		iA = ~inputsAmount, pA = ~pointsAmount;
		~guis[\mixer][\layouts][\inputs].add(~guis[\mixer][\inputs][num][\layouts][\main]);
		label.string = 'Input ' ++ (num + 1);
		label.align = \center;
		//label.fixedHeight_(20);
		~guis[\mixer][\inputs][num][\layouts][\main].add(label, align:\center);
		~guis[\mixer][\inputs][num].put(\label,label);
		~guis[\mixer][\inputs][num][\layouts][\main].add(~guis[\mixer][\inputs][num][\layouts][\mixSends]);
		~guis[\mixer][\inputs][num][\layouts][\main].add(~guis[\mixer][\inputs][num][\layouts][\pointSends]);
		lblMixSends.string = 'Mix Sends';
		lblMixSends.align = \center;
		//lblPointSends.fixedHeight_(20);
		~guis[\mixer][\inputs][num][\layouts][\mixSends].add(lblMixSends, align:\center);
		~mixesAmount.do({
			arg count;
			var label = StaticText.new(~tabMixer),
			slider = Slider.new(~tabMixer);
			slider.orientation_(\horizontal);
			~guis[\mixer][\inputs][num][\layouts][\mixSends].add(~guis[\mixer][\inputs][num][\mixSends][count][\layout]);
			label.string = '' ++ (count + 1);
			label.align = \center;
			//label.fixedHeight_(20);
			~guis[\mixer][\inputs][num][\mixSends][count][\layout].add(label, align:\center);
			~guis[\mixer][\inputs][num][\mixSends][count].put(\label,label);
			slider.action_({
				arg obj;
				var dbVol = obj.value;
				~inputs[num].at('mix' ++ count ++ \sendSynth).set(\amp,dbVol).trace;
			});
			~guis[\mixer][\inputs][num][\mixSends][count][\layout].add(slider);
			~guis[\mixer][\inputs][num][\mixSends][count].put(\slider,slider);
			//var sliderTag =
			~inputs[num].put('mix' ++ count ++ \sendSlide,slider);
		});
		lblPointSends.string = 'Point Sends';
		lblPointSends.align = \center;
		//lblPointSends.fixedHeight_(20);
		~guis[\mixer][\inputs][num][\layouts][\pointSends].add(lblPointSends, align:\center);
		~pointsAmount.do({
			arg count;
			var label = StaticText.new(~tabMixer),
			slider = Slider.new(~tabMixer);
			slider.orientation_(\horizontal);
			~guis[\mixer][\inputs][num][\layouts][\pointSends].add(~guis[\mixer][\inputs][num][\pointSends][count][\layout]);
			label.string = '' ++ (count + 1);
			label.align = \center;
			//label.fixedHeight_(20);
			~guis[\mixer][\inputs][num][\pointSends][count][\layout].add(label, align:\center);
			~guis[\mixer][\inputs][num][\pointSends][count].put(\label,label);
			slider.action_({
				arg obj;
				var dbVol = obj.value;
				~inputs[num].at('point' ++ count ++ \sendSynth).set(\amp,dbVol).trace;
			});
			~guis[\mixer][\inputs][num][\pointSends][count][\layout].add(slider);
			~guis[\mixer][\inputs][num][\pointSends][count].put(\slider,slider);
			//var sliderTag =
			~inputs[num].put('point' ++ count ++ \sendSlide,slider);
		});
	});

	~mixesAmount.do({
		arg num;
		var label = StaticText.new(~tabMixer),
		lblPointSends = StaticText.new(~tabMixer),
		wH = ~windowHeight - ~viewMain.tabHeight,
		wW = ~windowWidth,
		pA = ~pointsAmount, hO = ~hwOutputs;
		~guis[\mixer][\layouts][\mixes].add(~guis[\mixer][\mixes][num][\layouts][\main]);
		label.string = 'Mix ' ++ (num + 1);
		label.align = \center;
		//label.fixedHeight_(20);
		~guis[\mixer][\mixes][num][\layouts][\main].add(label, align:\center);
		~guis[\mixer][\mixes][num].put(\label,label);
		~guis[\mixer][\mixes][num][\layouts][\main].add(~guis[\mixer][\mixes][num][\layouts][\pointSends]);
		lblPointSends.string = 'Point Sends';
		lblPointSends.align = \center;
		//lblOutSends.fixedHeight_(20);
		~guis[\mixer][\mixes][num][\layouts][\pointSends].add(lblPointSends, align:\center);
		~pointsAmount.do({
			arg count;
			var label = StaticText.new(~tabMixer),
			slider = Slider.new(~tabMixer);
			slider.orientation_(\horizontal);
			~guis[\mixer][\mixes][num][\layouts][\pointSends].add(~guis[\mixer][\mixes][num][\pointSends][count][\layout]);
			label.string = '' ++ (count + 1);
			label.align = \center;
			//label.fixedHeight_(20);
			~guis[\mixer][\mixes][num][\pointSends][count][\layout].add(label, align:\center);
			~guis[\mixer][\mixes][num][\pointSends][count].put(\label,label);
			slider.action_({
				arg obj;
				var dbVol = obj.value;
				~mixes[num].at('point' ++ count ++ \sendSynth).set(\amp,dbVol).trace;
			});
			~guis[\mixer][\mixes][num][\pointSends][count][\layout].add(slider);
			~guis[\mixer][\mixes][num][\pointSends][count].put(\slider,slider);
			//var sliderTag =
			~mixes[num].put('point' ++ count ++ \sendSlide,slider);
			//((wH / 2) + ((wH / 2 / hO)*count)).postln;
		});
	});

	~pointsAmount.do({
		arg num;
		var label = StaticText.new(~tabMixer),
		lblOutSends = StaticText.new(~tabMixer),
		wH = ~windowHeight - ~viewMain.tabHeight,
		wW = ~windowWidth,
		pA = ~pointsAmount, hO = ~hwOutputs;
		~guis[\mixer][\layouts][\points].add(~guis[\mixer][\points][num][\layouts][\main]);
		label.string = 'Point ' ++ (num + 1);
		label.align = \center;
		//label.fixedHeight_(20);
		~guis[\mixer][\points][num][\layouts][\main].add(label, align:\center);
		~guis[\mixer][\points][num].put(\label,label);
		~guis[\mixer][\points][num][\layouts][\main].add(~guis[\mixer][\points][num][\layouts][\outputSends]);
		lblOutSends.string = 'Output Sends';
		lblOutSends.align = \center;
		//lblOutSends.fixedHeight_(20);
		~guis[\mixer][\points][num][\layouts][\outputSends].add(lblOutSends, align:\center);
		~outputsAmount.do({
			arg count;
			var label = StaticText.new(~tabMixer),
			slider = Slider.new(~tabMixer);
			slider.orientation_(\horizontal);
			~guis[\mixer][\points][num][\layouts][\outputSends].add(~guis[\mixer][\points][num][\outputSends][count][\layout]);
			label.string = '' ++ (count + 1);
			label.align = \center;
			//label.fixedHeight_(20);
			~guis[\mixer][\points][num][\outputSends][count][\layout].add(label, align:\center);
			~guis[\mixer][\points][num][\outputSends][count].put(\label,label);
			slider.action_({
				arg obj;
				var dbVol = obj.value;
				~points[num].at('output' ++ count ++ \sendSynth).set(\amp,dbVol).trace;
			});
			~guis[\mixer][\points][num][\outputSends][count][\layout].add(slider);
			~guis[\mixer][\points][num][\outputSends][count].put(\slider,slider);
			//var sliderTag =
			~points[num].put('hwOut' ++ count ++ \sendSlide,slider);
			//((wH / 2) + ((wH / 2 / hO)*count)).postln;
		});
	});
};

~wdw.front;
~wdw.alwaysOnTop_(true);

StaticText.




s.quit;
s.reboot;

s.plotTree;

s.meter;

//TESTING

SynthDef(\outVolumeCtrl, {
	arg busIn=0, busOut=0, amp=0;
	Out.ar(busOut, In.ar(busIn,1) * amp);
}).add;

~grp1 = Group.new();
~grp2 = Group.after(~grp1);
~grp1;

~busTest = Bus.audio(s,1);

~synthTest = Synth(\outVolumeCtrl,[\busIn,4,\busOut,~busTest], ~grp1);
~synthTest2 = Synth(\outVolumeCtrl,[\busIn,~busTest,\busOut,0], ~grp2);

~wTest = Window.new('mixerTest', Rect(
	Window.screenBounds.width/2-400,
	Window.screenBounds.height/2-300,
	800,
	600));

~sliderTest = Slider.new(~wTest.view, Rect.new(
		100,
		100,
		400,
	100));
	~sliderTest.action_({
		arg obj;
		var dbVol = obj.value;
		~synthTest.set(\amp,dbVol).trace;
	});
~sliderTest2 = Slider.new(~wTest.view, Rect.new(
		100,
		220,
		400,
	100));
	~sliderTest2.action_({
		arg obj;
		var dbVol = obj.value;
		~synthTest2.set(\amp,dbVol).trace;
	});

~synthTest2.set(\busOut,2);

~wTest.front;

~buses[\point][0][\in];
~inputs[0];
~inputs[0][\busIn];
~inputs[0][\outVol0];
~points[0][\busIn];












s.options.numAudioBusChannels = 35072;
s.options.memSize = 1048576; //1048576KB = 1GB

s.reboot;

s.options.numAudioBusChannels;
var devs = ServerOptions.devices;
devs.do {
	arg item; item.postln;
}

~x = 5;
~x;
~y = ~x.asString;
~y;


s.options.numInputBusChannels.postln;
s.options.numOutputBusChannels.postln;

s.meter;
s.plotTree;

//FOA Example
~order = 3;
~numChans = 24;
~tdesign = TDesign.newHoa(~numChans, order: ~order);

~tdesign.visualize;

~decoder = FoaDecoderMatrix.newQuad(k: 'dual');
~renderDecode = { arg in, decoder;
    var kind;
    var fl, bl, br, fr;
    var fc, lo;
    var sl, sr;
    var flu, blu, bru, fru;
    var fld, bld, brd, frd;
    var slu, sru, sld, srd;
	#fl, bl, br, fr = FoaDecode.ar(in, decoder);
	//[fl, fr, bl, br]
};

~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "\\b-format\\Anderson-Pacific_Slope.wav");
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Howle-Calling_Tunes.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Pampin-On_Space.wav")
~sndbuf;

~atkSig;
(
{
    //var sig;                            // audio signal


    // display encoder and decoder
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;

    // ------------------------------------------------------------
    // test sig
    ~atkSig = PlayBuf.ar(~sndbuf.numChannels, ~sndbuf, BufRateScale.kr(~sndbuf), doneAction:2);   // soundfile


    // ------------------------------------------------------------
    // decode (via ~renderDecode)
    ~renderDecode.value(sig, ~decoder)

}.scope;
)

// free buffer
~sndbuf.free

//HOA Example
~order = 1;
~directions = [30.0, 135.0, -135.0, -30.0].degrad;
~beamShape = \energy;
~match = \energy;

~decoder = HoaMatrixDecoder.newModeMatch(~directions, ~beamShape, ~match, ~order);
~decRadius = 1.0;

~tmyConfig = HoaDecodeMatrix.ar(
	HoaNFCtrl.ar(
		PlayBuf.ar(~sndbuf.numChannels, ~sndbuf, BufRateScale.kr(~sndbuf), doneAction:2),
		AtkHoa.refRadius,
		~decRadius,
		~decoder.order
	),
	~decoder
);

//ATK Simple Construction

//1 hoa synth ~= 1,1% CPU.   Extrapolating to 90 channels = 100% CPU

//Server config:
//16 channels
//8 mixes
//16 points - 192hoach
//8 fields
//4 spaces

s.quit;

//s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.inDevice = "Windows WASAPI : CABLE Output (VB-Audio Virtual Cable)";
s.options.outDevice = "Windows WASAPI : Line (Realphones System-Wide)";
s.options.sampleRate = 48000;
//s.options.hardwareBufferSize = 4096;
s.options.numOutputBusChannels = 2;
//s.latency = 0.2;

s.boot;

//FOA Case
SynthDef(\sndPan, {
	arg busIn, busOut, amp=0, angRot = 0, omni = 1;
	var snd = In.ar(busIn * amp,1);
	snd = FoaEncode.ar(snd, FoaEncoderMatrix.newDirection(0,0));
	snd = FoaRotate.ar(snd,angRot);
	snd = FoaDirectO.ar(snd,angDir);
	snd = FoaDecode.ar(snd,FoaDecoderMatrix.newDiametric([30.0, 135.0, -135.0, -30.0].degrad, k: 'dual'));
	Out.ar(busOut, snd);
}).add;

//HOA Case
~hoaEncRadius = 1.0;
~hoaDirections = [30.0, 135.0, -135.0, -30.0].degrad;
~hoaBeamShape = \basic;
~hoaMatch = \amp;
~hoaOrder = 3;

~freq = 30.0;
~binaurEnc = FoaEncoderMatrix.newHoa1;
~binaurDec = FoaDecoderKernel.newCIPIC;

SynthDef(\sndPan, {
	arg busIn, busOut, amp=0, angRot = 0, angElev = 0, omni = 0;
	var sndIn, sndFr, sndBk, sndHoa, amp1, amp2;

	sndIn = SoundIn.ar(busIn, 1);

	amp1 = amp * (1 -omni);
	amp2 = omni * amp / 2;

	sndFr = HoaEncodeDirection.ar(sndIn, angRot, angElev, ~hoaEncRadius, ~hoaOrder);
	sndBk = HoaEncodeMatrix.ar((sndIn)!4, HoaMatrixEncoder.newDirections(
		[[0,pi/2],[0,-0.6154797],[pi*1.5,-0.6154797],[-pi*1.5,-0.6154797]],
		~hoaBeamShape, ~hoaMatch, ~hoaOrder));

	sndHoa = Mix.new([sndFr * amp1, sndBk * amp2]);

	//To Loudspeakers
	/*sndHoa = HoaDecodeMatrix.ar(sndHoa, HoaMatrixDecoder.newModeMatch(
		~hoaDirections,
		beamShape: ~hoaBeamShape,
		match: ~hoaMatch,
		order: ~hoaOrder));*/

	//To Binaural Headphones
	sndHoa = FoaDecode.ar(
		FoaProximity.ar(
			HPF.ar(
				FoaEncode.ar(
					sndHoa.keep(AtkFoa.defaultOrder.asHoaOrder.size),
					~binaurEnc
				),
				~freq
			),
			AtkHoa.refRadius
		),
		~binaurDec);

	Out.ar(busOut, sndHoa);
}).add;


~atkSynth = Synth(\sndPan,[\busIn,0,\busOut,0]);

~wAtk = Window.new('atkPan', Rect(
	Window.screenBounds.width/2-400,
	Window.screenBounds.height/2-300,
	800,
	600));

~sldVol = Slider.new(~wAtk.view, Rect.new(
		100,
		100,
		400,
	100));
	~sldVol.action_({
		arg obj;
	var amp = obj.value * 4;
		~atkSynth.set(\amp,amp);
	});
~sldRot = Slider.new(~wAtk.view, Rect.new(
		100,
		220,
		400,
	100));
	~sldRot.action_({
		arg obj;
	var angle = (obj.value*2 - 1) * pi;
	~atkSynth.set(\angRot,angle);
	});
~sldElev = Slider.new(~wAtk.view, Rect.new(
		100,
		340,
		400,
	100));
	~sldElev.action_({
		arg obj;
	var angle = (obj.value * 2 - 1) * pi / 2;
	~atkSynth.set(\angElev,angle);
	});
~sldRad = Slider.new(~wAtk.view, Rect.new(
		100,
		460,
		400,
	100));
	~sldRad.action_({
		arg obj;
	var omni = obj.value;
	~atkSynth.set(\omni,omni);
	});


~wAtk.front;

s.meter;
s.plotTree;
s.options.device;

~atkSynth.run(false);
~atkSynth.run(true);


FoaXformDisplay.new(8);
FoaDirectO

HoaBalance
HoaEncodeDirection.ar()

Atk.userSoundsDir;
(
var y, z;
z = [1, 2, 3, 4];
y = z.addAll([7, 8, 9]);
z.postln;
y.postln;
)

(4.log10)*20.postln;
4.ampdb.postln;

pow(10,(12/20));
12.dbamp;

FoaPush
Hoa
	//assymetry
	//dominate
	//press
	//focus
	//direct
	//directO
	//mirror
	//NFC
	//RTT

	//HOA Transformers
	//assymetry
	//Beam
	//dominate
	//focus
	//RTT
	//reflect
	//Null
	//NFC

	// x - Tilt / roll
	// y - Tumble / pitch
	// z - Rotate / yaw

	//RTT
	//assymetry
	//focus
	//Reflect
	//Null
	//NFC

//OSC Interaction
s.quit;
s.boot;

NetAddr.langPort;

OSCdef.new(\dlsp,
	{
		arg msg,time,addr,port;
	var str = 'dlsp';
	str.postln;
},
	'/dlsp');


// Create a Window with a StaticText
(
w=Window().alwaysOnTop_(true);
t=StaticText(w);
w.front;
)

// There's no text set yet. Post the sizeHint of StaticText:
t.sizeHint

// Set the text, and post the sizeHint again:
t.string_("This is a looooooong text");
t.sizeHint

// Adjust the size to the sizeHint:
t.bounds = t.bounds.size_(t.sizeHint);

// Now you can see the whole text
