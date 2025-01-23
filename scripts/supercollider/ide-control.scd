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

~devicesList = ServerOptions.devices;
~devicesList.do ({
	arg item;
	item.postln;
});

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
~vmOpt[\rate]=0.1;
OSCFunc.trace(false);
OSCFunc.trace(true);

'message'.postln;

(
var y, z;
z = [1, 2, 3, 4];
y = z ++ [7, 8, 9];
z.postln;
y.postln;
)

~prlg;
try {
	~prlg = this.inte("4+3{{");
} { |error|
	error.dump;
}

~prlg.post;

~arrayt = [1,2,3];
~arrayt[3].postln;

~arrayt.isStr

~vm[\inputs][\in].postln;


~var1 = nil;

~var2 = ~var1.asInteger;
~var2.postln;

if (~var1 < 3) {~bool1 = true} {~bool1=false}
~bool1.postln;

Quarks.gui;

VSTPlugin.search;

~vstArray = VSTPlugin.pluginList(s,true);

~vstArray.do({
	arg item;
	item.postln;
});


// ------------------------------------------------------------
// Binaural (synthetic) decoder
//
// mono pink noise source
// omni encoder


// define encoder / decoder matrices
~encoder = FoaEncoderMatrix.newOmni
~decoder = FoaDecoderKernel.newSpherical // kernel decoders should be freed after use!!
                                         // free below...
server.killAll;
s.boot;
// inspect
~encoder.kind
~encoder.numChannels
~encoder.dirChannels

~decoder.kind
~decoder.numChannels
~decoder.dirChannels.raddeg

(
{
    var sig;// audio signal
    var angle, azim;            // angle and azimuth control


    // display encoder and decoder
    "Ambisonic encoding via % encoder".format(~encoder.kind).postln;
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;

    // angle ---> top    = push to plane wave
    //            bottom = omni-directional
    angle = MouseY.kr(pi/2, 0);

    // azimuth -> hard left     = back
    //          centre     = centre
    //          hard right     = back
    azim = MouseX.kr(pi, -pi);


    // ------------------------------------------------------------
    // test sig
    sig = PinkNoise.ar;             // mono pink noise


    // ------------------------------------------------------------
    // encode
    sig = FoaEncode.ar(sig, ~encoder);

    // ------------------------------------------------------------
    // transform
    sig = FoaTransform.ar(sig, 'push', angle, azim);


    // ------------------------------------------------------------
    // decode (to binaural)
    FoaDecode.ar(sig, ~decoder);

}.scope;
)

// free kernel
~decoder.free
s.quit;

// ------------------------------------------------------------

// ------------------------------------------------------------
// Binaural (CIPIC) decoder
//
// mono pink noise source
// omni encoder

s.boot;
// define encoder / decoder matrices
~encoder = FoaEncoderMatrix.newOmni
~decoder = FoaDecoderKernel.newCIPIC    // kernel decoders should be freed after use!!
                                        // free below...

// inspect
~encoder.kind
~encoder.numChannels
~encoder.dirChannels

~decoder.kind
~decoder.numChannels
~decoder.dirChannels.raddeg

(
{
    var sig;// audio signal
    var angle, azim;            // angle and azimuth control


    // display encoder and decoder
    "Ambisonic encoding via % encoder".format(~encoder.kind).postln;
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;

    // angle ---> top         = push to plane wave
    //            bottom        = omni-directional
    angle = MouseY.kr(pi/2, 0);

    // azimuth -> hard left     = back
    //          centre     = centre
    //          hard right     = back
    azim = MouseX.kr(pi, -pi);


    // ------------------------------------------------------------
    // test sig
    sig = PinkNoise.ar;             // mono pink noise


    // ------------------------------------------------------------
    // encode
    sig = FoaEncode.ar(sig, ~encoder);

    // ------------------------------------------------------------
    // transform
    sig = FoaTransform.ar(sig, 'push', angle, azim);


    // ------------------------------------------------------------
    // decode (to binaural)
    FoaDecode.ar(sig, ~decoder);

}.scope;
)

// free kernel
~decoder.free

// ------------------------------------------------------------
s.meter;
s.status.postln;
~buses.postln;
~inputsMonoAmount.postln;

NetAddr.langPort;

thisProcess.openUDPPort(57110);
thisProcess.openPorts;

OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off

s.options.device = "ASIO : Dante Virtual Soundcard (x64)";
s.options.sampleRate = 48000;
s.boot;
s.serverRunning;
s.ping;
Server.killAll;

~inputsMono[0].postln;
1 - 0.3.clip(0,1).postln;
AtkFoa.format;
AtkFoa.ordering;
AtkFoa.normalisation;
AtkFoa.speedOfSound;

~decoderRoom.dirChannels;
~serverConf[\mainDirections][0];

[45,-45].degrad;
[0,5]


~decoder1 = FoaDecoderMatrix.newFromMatrix(Matrix.with([[1,2],[2,2],[3,2],[4,2],[5,2],[6,2],[7,2],[8,2]]),
	[
		~serverConf[\mainDirections][0],
		~serverConf[\mainDirections][1],
		~serverConf[\mainDirections][2],
		~serverConf[\mainDirections][3],
		~serverConf[\mainDirections][4],
		~serverConf[\mainDirections][5],
		~serverConf[\mainDirections][6],
		~serverConf[\mainDirections][7],
	]
);