////FIRST RUN INSTALLS

//Installed GIT required.
Quarks.gui;

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



Server.killAll;
s.quit;

////REGULAR RUN

// SETTINGS

~hwInputs = 4;
~hwOutputs = 4;

~inputsAmount = 4;
~pointsAmount = 4;

~windowHeight = 600;
~windowWidth = 800;

//START
s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.sampleRate = 48000;
s.options.numInputBusChannels = ~hwInputs;
s.options.numOutputBusChannels = ~hwOutputs;

s.boot;

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
w = Window.new('mixer', Rect(
	(Window.screenBounds.width / 2) - (~windowHeight / 2),
	(Window.screenBounds.height / 2) - (~windowWidth / 2),
	~windowWidth,
	~windowHeight));

~inputsAmount.do({
	arg num;
	var wH = ~windowHeight, wW = ~windowWidth, iA = ~inputsAmount, pA = ~pointsAmount;
	~pointsAmount.do({
		arg count;
		var slider = Slider.new(w.view, Rect.new(
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
	var wH = ~windowHeight, wW = ~windowWidth, pA = ~pointsAmount, hO = ~hwOutputs;
	~hwOutputs.do({
		arg count;
		var slider = Slider.new(w.view, Rect.new(
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
});

w.front;
w.alwaysOnTop_(true);








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
s.quit;

s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.sampleRate = 48000;
s.options.numOutputBusChannels = 4;

s.boot;

//FOA Case
SynthDef(\sndPan, {
	arg busIn, busOut, amp=0, angRot = 0, angDir = pi / 2;
	var snd = In.ar(busIn,1);
	snd = FoaEncode.ar(snd, FoaEncoderMatrix.newDirection(0,0), amp);
	snd = FoaRotate.ar(snd,angRot);
	snd = FoaDirectO.ar(snd,angDir);
	snd = FoaDecode.ar(snd,FoaDecoderMatrix.newDiametric([30.0, 135.0, -135.0, -30.0].degrad, k: 'dual'));
	Out.ar(busOut, snd);
}).add;

//HOA Case
~hoaEncRadius = 1;
~hoaDirections = [30.0, 135.0, -135.0, -30.0].degrad;
~hoaBeamShape = \basic;
~hoaMatch = \amp;
~hoaOrder = 5;

SynthDef(\sndPan, {
	arg busIn, busOut, amp=0, angRot = 0, angElev = 0, angDir = pi / 2;
	var snd = In.ar(busIn * amp, 1);
	snd = HoaEncodeDirection.ar(snd,angRot,angElev, ~hoaEncRadius, ~hoaOrder);
	snd = HoaDecodeMatrix.ar(snd, HoaMatrixDecoder.newModeMatch(
		~hoaDirections,
		beamShape: ~hoaBeamShape,
		match: ~hoaMatch,
		order: ~hoaOrder));
	Out.ar(busOut, snd);
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
		var dbVol = obj.value;
		~atkSynth.set(\amp,dbVol).trace;
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
~sldDir = Slider.new(~wAtk.view, Rect.new(
		100,
		340,
		400,
	100));
	~sldDir.action_({
		arg obj;
	var angle = (obj.value * 2 - 1) * pi / 2;
	~atkSynth.set(\angElev,angle);
	});

~wAtk.front;

s.meter;
s.plotTree;
s.options.device;

FoaXformDisplay.new(8);
FoaDirectO




Atk.userSoundsDir;
HoaMatrixDecoder