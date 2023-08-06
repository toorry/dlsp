Server.killAll;
s.quit;

// SETTINGS

~inputBuses = 4;
~outputBuses = 4;

~inputsAmount = 4;
~pointsAmount = 4;

~windowHeight = 800;
~windowWidth = 600;

//START
s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.sampleRate = 48000;
s.options.numInputBusChannels = ~inputBuses;
s.options.numOutputBusChannels = ~outputBuses;

s.boot;

//Initialise BUSES
~busSilent = Bus.audio(s,1);

~buses = Dictionary();
~buses.put(\input,Array.newClear(~inputsAmount));
~buses.put(\point,Array.newClear(~pointsAmount));
~buses[\input].do ({
	arg item;
	item.add(Bus.audio(s,1));
})
~buses[\point].do ({
	arg item;
	item.add(Bus.audio(s,1));
})

//Initialise INPUTS
~inputs = Array.new(maxSize: 128);
~inputsAmount.do({
	arg item;
	var input = Dictionary();
	input.put(\busIn,item);
	//input.put(\outVolume,Bus(audio(s,1)));
	~inputs.add(input).postln;
});

//Initialise BUSES for POINTS
~points = Array.new(maxSize: 128);
~pointsAmount.do({
	//arg item;
	var point = Dictionary();
	point.put(\busIn,Bus.audio(s,1));
	//point.put(\outVolume,Bus(audio(s,1)));
	~points.add(point).postln;
});

//Initialise INPUT & POINT Out Volumes
SynthDef(\outVolume, {
	arg busIn, busOut, amp=0;
	Out.ar(busOut, SoundIn.ar(busIn,1) * amp);
}).add;

~inputs.do({
	arg item;
	~pointsAmount.do({
		arg num;
		//item.put(\outVol, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[num].at(\busIn)])).postln;
		var name = 'outVol'++num.asString;
		num.postln;
		item.at(\busIn).postln;
		item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, num])).postln;
	});
});

~points.do({
	arg item;
	~outputBuses.do({
		arg num;
		item.put(\outVol+num, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, Out.ar(num,1)])).postln;
	});
});

~inputs;
~points;

//Initialise GUI
w = Window.new('mixer', Rect(
	(Window.screenBounds.width / 2) - (~windowHeight / 2),
	(Window.screenBounds.height / 2) - (~windowWidth / 2),
	~windowHeight,
	~windowWidth));

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
		~inputs[num].put(\outVol++count.asString+\Slide,slider).postln;
	})
});

~pointsAmount.do({
	arg num;
	var slider = Slider.new(w.view, Rect.new(
		(~windowWidth / ~pointsAmount)*num,
		(~windowHeight / 2) +(~windowHeight / 2 / ~outputBuses)*num,
		(~windowWidth / ~pointsAmount),
		(~windowHeight / 2 /~outputBuses)
	));
	slider.action_({
		arg obj;
		var dbVol = obj.value;
		~inputs[num].at(\outVol).set(\amp,dbVol).trace;
	});
	~points[num].put(\outVolSlide,slider);
})

w.front;
w.alwaysOnTop_(true);








s.reboot;

s.plotTree;

s.meter;

//TESTING

SynthDef(\outVolumeCtrl, {
	arg busIn=0, busOut=0, amp=0;
	Out.ar(busOut, SoundIn.ar(busIn,1) * amp);
}).add;

~synthTest = Synth(\outVolumeCtrl);

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

~synthTest.set(\busOut,2);

~wTest.front;














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