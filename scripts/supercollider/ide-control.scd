~sample1 = Buffer.read(s,"/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav" );
~sample2 = Buffer.read(s, "/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav");

SynthDef.new(\sample, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 1.0);
	//Out.kr(~buses[\input][0][\inCtrl], Mix.kr(sig) * 10);
	Out.ar(~buses[\hwOut][0], Mix.ar(sig) * 0.5);
}).add;

SynthDef.new(\sampleCtrl, {
	var sig;
	sig = PlayBuf.ar(2, ~sample2, loop: 1.0);
	Out.kr(~buses[\input][0][\in], Mix.ar(sig) * 0.5);
	//Out.ar(~buses[\hwOut][0], Mix.ar(sig) * 0.5);
}).add;

Synth.new(\sample);
Synth.new(\sampleCtrl);

s.meter;

-1.abs.postln;