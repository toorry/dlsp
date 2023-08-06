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

// SETTINGS

~hwInputs = 2;
~hwOutputs = 2;

~inputsAmount = 8;
~mixesAmount = 4;
~pointsAmount = 8;
~fieldsAmount = 4;
~spacesAmount = 4;

~windowHeight = 600;
~windowWidth = 800;

//START
//s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.inDevice = "Windows WASAPI : Microphone (Realtek(R) Audio)";
s.options.outDevice = "Windows WASAPI : Line (Realphones System-Wide)";
s.options.hardwareBufferSize = 256;
//s.options.hardwareBufferSize;
s.options.sampleRate = 48000;
s.options.numInputBusChannels = ~hwInputs;
s.options.numOutputBusChannels = ~hwOutputs;
s.options.memSize = 1048576; //1048576KB = 1GB
s.boot;

~netSend = NetAddr.new("127.0.0.1",7799);
~netRecv = NetAddr.new("127.0.0.1",7797);

//Initialise BUSES
~busSilent = Bus.audio(s,1);

~buses = Dictionary();
~buses.put(\hwIn,Array.newClear(~hwInputs));
~buses.put(\hwOut,Array.newClear(~hwOutputs));
~buses.put(\input,Array.newClear(~inputsAmount));
~buses.put(\point,Array.newClear(~pointsAmount));

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

~pointsAmount.do ({
	arg num;
	var item = Dictionary();
	item.put(\in,Bus.audio(s,1));
	~buses[\point][num]=item;
});
~buses[\point].postln;

//Initialise INPUTS
~inputs = Array.newClear(~inputsAmount);
~inputsAmount.do({
	arg num;
	var input = Dictionary();
	input.put(\busIn,~buses[\hwIn][num]);
	//input.put(\outVolume,Bus(audio(s,1)));
	~inputs[num] = input;
});
~inputs.postln;

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

//Initialise GROUPS
~grpInputs = Group.new;
~grpPoints = Group.after(~grpInputs);

//Initialise INPUT & POINT Out Volumes
SynthDef(\outVolume, {
	arg busIn, busOut, amp=0;
	Out.ar(busOut, In.ar(busIn,1) * amp);
}).add;

~inputs.do({
	arg item;
	~pointsAmount.do({
		arg num;
		//item.put(\outVol, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[num].at(\busIn)])).postln;
		var name = 'outVol'++num.asString;
		var log;
		//num.postln;
		//item.at(\busIn).postln;
		item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[num][\busIn]], ~grpInputs)).postln;
		log = 'input' ++ name ++ ' busIn=' ++ item.at(\busIn) ++ ' busOut=' ++ ~points[num][\busIn];
		log.postln;
	});
});

~points.do({
	arg item;
	~hwOutputs.do({
		arg num;
		var name = \outVol++num.asString;
		var log;
		item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~buses[\hwOut][num]], ~grpPoints));
		log = 'point' ++ name ++ ' busIn=' ++ item.at(\busIn) ++ ' busOut=' ++ ~buses[\hwOut][num];
		log.postln;
	});
});

//~inputs;
//~points;

//Initialise GUI

~guis = Dictionary();
~guis.put(\mixer, Dictionary());
~guis[\mixer].put(\layouts,Dictionary());
~guis[\mixer][\layouts].put(\main,VLayout.new());
~guis[\mixer][\layouts].put(\inputs,HLayout.new());
~guis[\mixer][\layouts].put(\points,HLayout.new());
~guis[\mixer].put(\inputs,Array.newClear(~inputsAmount));
~guis[\mixer].put(\points,Array.newClear(~pointsAmount));

~inputsAmount.do({
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
	~guis[\mixer][\inputs][num] = item;
});

~pointsAmount.do({
	arg num;
	var item = Dictionary ();
	item.put(\layouts, Dictionary());
	item[\layouts].put(\main, VLayout.new());
	item[\layouts].put(\outSends,VLayout.new());
	item.put(\outSends,Array.newClear(~hwOutputs));
	~hwOutputs.do({
		arg count;
		var item2 = Dictionary();
		item2.put(\layout, HLayout.new());
		item[\outSends][count] = item2;
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
~guis[\mixer][\layouts][\main].add(~guis[\mixer][\layouts][\points], stretch:0, align:\center);

//LineLayout
~inputsAmount.do({
	arg num;
	var label = StaticText.new(~tabMixer),
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
	~guis[\mixer][\inputs][num][\layouts][\main].add(~guis[\mixer][\inputs][num][\layouts][\pointSends]);
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
		label.string = 'Point ' ++ (count + 1);
		label.align = \center;
		//label.fixedHeight_(20);
		~guis[\mixer][\inputs][num][\pointSends][count][\layout].add(label, align:\center);
		~guis[\mixer][\inputs][num][\pointSends][count].put(\label,label);
		slider.action_({
			arg obj;
			var dbVol = obj.value;
			~inputs[num].at(\outVol++count.asString).set(\amp,dbVol).trace;
		});
		~guis[\mixer][\inputs][num][\pointSends][count][\layout].add(slider);
		~guis[\mixer][\inputs][num][\pointSends][count].put(\slider,slider);
		//var sliderTag =
		~inputs[num].put(\outVol++count.asString++\slide,slider);
	})
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
	~guis[\mixer][\points][num][\layouts][\main].add(~guis[\mixer][\points][num][\layouts][\outSends]);
	lblOutSends.string = 'Output Sends';
	lblOutSends.align = \center;
	//lblOutSends.fixedHeight_(20);
	~guis[\mixer][\points][num][\layouts][\outSends].add(lblOutSends, align:\center);
	~hwOutputs.do({
		arg count;
		var label = StaticText.new(~tabMixer),
		slider = Slider.new(~tabMixer);
		slider.orientation_(\horizontal);
		~guis[\mixer][\points][num][\layouts][\outSends].add(~guis[\mixer][\points][num][\outSends][count][\layout]);
		label.string = 'Output ' ++ (count + 1);
		label.align = \center;
		//label.fixedHeight_(20);
		~guis[\mixer][\points][num][\outSends][count][\layout].add(label, align:\center);
		~guis[\mixer][\points][num][\outSends][count].put(\label,label);
		slider.action_({
			arg obj;
			var dbVol = obj.value;
			~points[num].at(\outVol++count.asString).set(\amp,dbVol).trace;
		});
		~guis[\mixer][\points][num][\outSends][count][\layout].add(slider);
		~guis[\mixer][\points][num][\outSends][count].put(\slider,slider);
		//var sliderTag =
		~points[num].put(\outVol++count.asString++\slide,slider);
		((wH / 2) + ((wH / 2 / hO)*count)).postln;
	})
});

/*~inputsAmount.do({
	arg num;

	var wH = ~windowHeight - ~viewMain.tabHeight,
	wW = ~windowWidth,
	iA = ~inputsAmount, pA = ~pointsAmount;
	~pointsAmount.do({
		arg count;
		var slider = Slider.new(~tabMixer, Rect.new(
			(wW / iA)*num,
			(wH / 2 / pA)*count,
			(wW / iA),
			(wH / 2 / pA)
		));
		slider.action_({
			arg obj;
			var dbVol = obj.value;
			~inputs[num].at(\outVol++count.asString).set(\amp,dbVol).trace;
		});
		//var sliderTag =
		~inputs[num].put(\outVol++count.asString++\slide,slider);
	})
});

~pointsAmount.do({
	arg num;
	var wH = ~windowHeight - ~viewMain.tabHeight,
	wW = ~windowWidth,
	pA = ~pointsAmount, hO = ~hwOutputs;
	~hwOutputs.do({
		arg count;
		var slider = Slider.new(~tabMixer, Rect.new(
			(wW / pA)*num,
			(wH / 2) + ((wH / 2 / hO)*count),
			(wW / pA),
			(wH / 2 / hO)
		));
		slider.action_({
			arg obj;
			var dbVol = obj.value;
			~points[num].at(\outVol++count.asString).set(\amp,dbVol).trace;
		});
		//var sliderTag =
		~points[num].put(\outVol++count.asString++\slide,slider);
		((wH / 2) + ((wH / 2 / hO)*count)).postln;
	})
});*/

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

s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.sampleRate = 48000;
//s.options.hardwareBufferSize = 4096;
s.options.numOutputBusChannels = 4;
s.latency = 0.2;

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
//~hoaEncRadius = 1;
~hoaDirections = [30.0, 135.0, -135.0, -30.0].degrad;
//~hoaEncRadius = 0.0875;
//~hoaDirections = [[pi/2,0],[-pi/2,0]];
~hoaBeamShape = \basic;
~hoaMatch = \amp;
~hoaOrder = 1;

SynthDef(\sndPan, {
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
	//sndHoa = sndFr;
	sndHoa = HoaDecodeMatrix.ar(sndHoa, HoaMatrixDecoder.newModeMatch(
		~hoaDirections,
		beamShape: ~hoaBeamShape,
		match: ~hoaMatch,
		order: ~hoaOrder));
	Out.ar(busOut, sndHoa);
}).add;


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
