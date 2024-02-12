~sample1 = Buffer.read(s,"/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav" );
~sample2 = Buffer.read(s, "/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav");

SynthDef.new(\sample, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	//Out.kr(~buses[\input][0][\inCtrl], Mix.kr(sig) * 10);
	Out.ar(~buses[\hwOut][0], Mix.ar(sig) * 0.5);
}).add;

SynthDef.new(\sampleCtrl, {
	var sig;
	sig = PlayBuf.ar(2, ~sample2, loop: 0.0);
	Out.kr(~buses[\input][3][\inCtrl], Mix.ar(sig) * 0.5);
	//Out.ar(~buses[\hwOut][0], Mix.ar(sig) * 0.5);
}).add;

Synth.new(\sample);
Synth.new(\sampleCtrl);

s.meter;

-1.abs.postln;

~ostagec.sendMsg('/in/in/vu', 1, ~vuIn[0]);
~myoscaddr.sendMsg('/in/in/vu', 1, ~vuIn[0]);

OSCFunc.trace(true);
OSCFunc.trace(false);
1.do({'ok'.postln});

~myoscaddr.sendMsg('/vu/in', 6, 3);
~vu;
~vuSend.stop;

Platform.ideName.postln;
Platform.architecture.postln;
Platform.

ServerOptions.devices;

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