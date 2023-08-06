Server.killAll;
s.quit;

// SETTINGS

~inputBuses = 4;
~outputBuses = 4;

~inputsAmount = 4;
~pointsAmount = 4;

//START
s.options.device = "ASIO : Soundcraft USB Audio ASIO";
s.options.sampleRate = 48000;
s.options.numInputBusChannels = ~inputBuses;
s.options.numOutputBusChannels = ~outputBuses;

s.boot;

//Initialise INPUTS
~inputs = Array.new(maxSize: 128);
~inputsAmount.do({
	//arg item;
	var input = Dictionary();
	input.put(\busIn,Bus.audio(s,1));
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
	Out.ar(busOut, In.ar(busIn,1) * amp.dbamp);
}).add;

~inputs.do({
	arg item;
	~pointsAmount.do({
		arg num;
		//item.put(\outVol, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, ~points[num].at(\busIn)])).postln;
		var name = 'outVol'++num.asString;
		num.postln;
		item.put(name, Synth(\outVolume, [\busIn, item.at(\busIn), \busOut, Out.ar(num,1)])).postln;
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

~windowHeight = 800;
~windowWidth = 600;

//Initialise GUI
w = Window.new('mixer', Rect(
	Window.screenBounds.width/2-400,
	Window.screenBounds.height/2-300,
	800,
	600));

~inputsAmount.do({
	arg num;
	var wH = ~windowHeight, wW = ~windowWidth, iA = ~inputsAmount, pA = ~pointsAmount;
	~pointsAmount.do({
		arg count;
		var slider = Slider.new(w.view, Rect.new(
			(wW / iA)*num.floor,
			(wH / 2 / pA)*count.floor,
			(wW / iA).floor,
			(wH / 2 / pA).floor
		));
		slider.action_({
			arg obj;
			var dbVol = obj.value;
			~inputs[num].at(\outVol).set(\amp,dbVol).postln;
		});
		~inputs[num].put(\outVolSlide,slider);
	})
})

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
		~inputs[num].at(\outVol).set(\amp,dbVol).postln;
	});
	~points[num].put(\outVolSlide,slider);
})

w.front;
w.alwaysOnTop_(true);








s.reboot;

s.plotTree;

s.meter;

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