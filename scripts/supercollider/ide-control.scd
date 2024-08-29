//~sample1 = Buffer.read(s,"/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav" );
//~sample2 = Buffer.read(s, "/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav");
~sample1 = Buffer.read(s, "D:/Samples/Dreaming-Under-The-Stars-MP3(chosic.com).mp3" );
~sample2 = Buffer.read(s, "D:/Samples/Dreaming-Under-The-Stars-MP3(chosic.com).mp3" );

SynthDef.new(\sample1, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	Out.kr(~buses[\input][0][\inCtrl], Mix.kr(sig) * 0.5);
	Out.ar(~buses[\input][0][\in], Mix.ar(sig) * 0.5);
}).add;
SynthDef.new(\sample2, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	Out.kr(~buses[\input][1][\inCtrl], Mix.kr(sig) * 0.5);
	Out.ar(~buses[\input][0][\in], Mix.ar(sig) * 0.5);
}).add;
SynthDef.new(\sample3, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	Out.kr(~buses[\input][2][\inCtrl], Mix.kr(sig) * 0.5);
	Out.ar(~buses[\input][0][\in], Mix.ar(sig) * 0.5);
}).add;
SynthDef.new(\sample4, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	Out.kr(~buses[\input][3][\inCtrl], Mix.kr(sig) * 0.5);
	Out.ar(~buses[\input][0][\in], Mix.ar(sig) * 0.5);
}).add;

SynthDef.new(\sampleCtrl, {
	var sig;
	sig = PlayBuf.ar(2, ~sample2, loop: 0.0);
	Out.kr(~buses[\input][3][\inCtrl], Mix.ar(sig) * 0.5);
	//Out.ar(~buses[\hwOut][0], Mix.ar(sig) * 0.5);
}).add;

~synth1 = Synth.new(\sample1);
~synth2 = Synth.new(\sample2);
~synth3 = Synth.new(\sample3);
~synth4 = Synth.new(\sample4);

~synth1.free;
~synth2.free;
~synth3.free;
~synth4.free;

s.meter;
s.plotTree;

-1.abs.postln;

~ostagec.sendMsg('/in/in/vu', 1, ~vuIn[0]);
~myoscaddr.sendMsg('/in/in/vu', 1, ~vuIn[0]);

OSCFunc.trace(true);
OSCFunc.trace(false);
1.do({'ok'.postln});

~myoscaddr.sendMsg('/vu/in', 6, 3);
~vu;
~vmSend.stop;

Platform.ideName.postln;
Platform.architecture.postln;
Platform.

ServerOptions.devices;

"jackd --no-realtime -d alsa -d hw:MKII".unixCmd;

"jack_control stop".unixCmdGetStdOut;

~fromCons = "jack_control dpd device".unixCmdGetStdOut;
~fromCons.postln;

s.boot;
s.quit;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");

// connect all output channels with system
"SC_JACK_DEFAULT_OUTPUTS".setenv("system");
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_3,system:playback_5");




// Start server
s.boot;

SynthDef("system_freqScope1_shm", { arg in=0, fftBufSize = 2048, scopebufnum=1, rate=4, dbFactor = 0.02;
			var phase = 1 - (rate * fftBufSize.reciprocal);
			var signal, chain, phasor, halfSamples, mul;
			var fftbufnum = LocalBuf(fftBufSize, 1);
			mul = 0.00285;
			halfSamples = BufSamples.ir(fftbufnum) * 0.5;
			signal = In.ar(in);
			chain = FFT(fftbufnum, signal, hop: 0.75, wintype:1);
			chain = PV_MagSmear(chain, 1);
			phasor = halfSamples.pow(LFSaw.ar(rate/BufDur.ir(fftbufnum), phase, 0.5, 0.5)) * 2; // 2 to bufsize
			phasor = phasor.round(2); // the evens are magnitude
			ScopeOut2.ar( ((BufRd.ar(1, fftbufnum, phasor, 1, 1) * mul).ampdb * dbFactor) + 1, scopebufnum, fftBufSize/rate);
		}, [\kr, \ir, \ir, \ir, \kr]).add;

// create a new analyzer
FreqScope.new(400, 200, 0, server: s);

// basic sine
{ SinOsc.ar(2000, 0, 0.25) }.play(s);

// random saw
{ RLPF.ar(Saw.ar(110, 0.2), LFNoise2.kr(1,1e4,1e4), LFNoise2.kr(1, 0.2, 0.22)) }.play(s);

// modulate phase
{ SinOsc.ar(800, SinOsc.ar(XLine.kr(20, 8000, 10), 0, 2pi), 0.25) }.play(s);

// all harmonics
{ Blip.ar(200, Line.kr(1, 100, 10), 0.2) }.play(s);



//
~dict1 = Dictionary.new();
~dict1.put(\key1,'value1');
~dict1.put(\key2,'value2');
~dict1.keys.do({
	arg huy;
	huy.postln;
});
~dict1.keys;

~path;

~vmSend.play;
~vmSend.stop;
~vmSend.reset;
OSCFunc.trace(false);
OSCFunc.trace(true);