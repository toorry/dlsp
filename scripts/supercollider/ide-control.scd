//~sample1 = Buffer.read(s,"/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav" );
//~sample2 = Buffer.read(s, "/home/sndadmin/dlsp/work/sources/nature-essentials/QP01 0127 Canyon dove.wav");
~sample1 = Buffer.read(s, ~path +/+ "work" +/+ "sources" +/+ "Dreaming-Under-The-Stars-MP3(chosic.com).mp3" );
~sample2 = Buffer.read(s, ~path +/+ "work" +/+ "sources" +/+ "Dreaming-Under-The-Stars-MP3(chosic.com).mp3" );

SynthDef.new(\sample1, {
	var sig;
	sig = PlayBuf.ar(2, ~sample1, loop: 0.0);
	Out.ar(30, Mix.ar(sig) * 0.5);
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
~saveCurrentState.stop;
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
~serverConf[\mainDirections];

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
Quarks.gui;

File.getcwd;
File.exists("C:" +/+ "meganz" +/+ "dlsp" +/+ "working" +/+ "testhtml.html");
~testFileHtml = File.readAllString("C:" +/+ "meganz" +/+ "dlsp" +/+ "working" +/+ "testhtml.html");
("st"++~testFileHtml[15]++"end");

~testString1 = "first\n\nsecond".postln;
~testStrArray = ~testString1.split(separator: $\n);
("*"++~testStrArray[1]++"*").postln;

"fish.rtf".splitext;
"Imaginary/Directory/fish".splitext;

~testFileJSON = File.readAllString("C:" +/+ "meganz" +/+ "dlsp" +/+ "working" +/+ "mixpage.state").parseJSON;
~testFileJSON.do ({
	arg item;
	item.postln;
});

~path;
~stateCurrent;
~stateLoaded;
~stateCurrent[\decoderMain][\directions];
~stateCurrent.put(\type, "dlspScene");
~stateCurrent.put(\dlspSceneVersion, "0.1");
~stateCurrent.put(\inputsMono, Array.newClear(~serverConf[\inputsMonoAmount]));
~serverConf[\inputsMonoAmount].do ({
	arg num;
	var item = Dictionary.new();
	item.put(\number, num + 1);
	item.put(\name, ~inputsMono[num][\name]);
	item.put(\name, ~inputsMono[num][\name]);
	item.put(\name, ~inputsMono[num][\name]);
	item.put(\name, ~inputsMono[num][\name]);
	~stateCurrent[\inputsMono][num] = Dictionary.new();

});

File.exists(~path +/+ "settings.dlspcfg");
File.exists(~path +/+ "states" +/+ "current.dlspstate");
JSONlib.
~dlspSettings;
~serverConf[\ambChansAmount];
~serverConf[\decoderMainSpeakersAmount];
~stateCurrent[\inputsMono][0][\];
~param2.postln;
~stateCurrent[\inputsMono][0][\gain];
~stateLoaded[\inputsMono][0][\gain];
~inputsMono[0][\synthInGain].get(\gain, {arg gain; gain.postln;});
~stateCurrent[\inputsMono][0][\mute];
~inputsMono[0][\synthInAmbPan].get(\mute, {arg mute; mute.postln;});
~stateCurrent[\inputsMono][0][\azim];
~inputsMono[0][\synthInAmbPan].get(\azimuth, {arg n; n.postln;});
~stateCurrent[\inputsMono][0][\elev];
~inputsMono[0][\synthInAmbPan].get(\elevation, {arg n; n.postln;});
~stateCurrent[\inputsMono][0][\dist];
~inputsMono[0][\synthInAmbPan].get(\radius, {arg n; n.postln;});
~inputsMono[0][\synthInAmbPan].get(\distance, {arg n; n.postln;});
~stateCurrent[\inputsMono][0][\volume];
~inputsMono[0][\synthInAmbSend].get(\volume, {arg volume; volume.postln;});
~defaultValues[\inGain];
~defaultValues[\inDist];
~serverConf[\roomRadius];
~inputsMono[0][\gain];
~inputsMono[0][\dist];
~stateCurrent[\inputsMono][0][\dist];
~points[0][\synthGain].set(\gain, 1);
~points[0][\synthPan].set(\azimuth, 0);
~points[0][\synthGain];
~points[0][\synthPan]
~stateCurrent[\points][1][\gain];
~ostagec.sendMsg("/fb", "ch", "i", 1, "gn", ~stateCurrent[\points][0][\gain]);
~fields[0][\synthSend].set(\volume, 1);
~fields[0][\synthTransform].set(\volume, 1);
~fields[0][\synthTransform].set(\mute, 1);
~fields[0][\synthTransform].set(\busOut, ~buses[\ambMain]);
~fields[0][\synthTransform].set(\busIn, 14);
~fields[0][\busIn]
(~hwOutputs + ~serverConf[\pointsAmount] + ((1 - 1) * ~serverConf[\fieldsAmount])).postln;
~hwOutputs
~serverConf[\pointsAmount]
~serverConf[\fieldsAmount]
~buses[\ambMain]
~hwOutputs + ~serverConf[\pointsAmount] + ((1 - 1) * ~serverConf[\ambChansAmount])
~buses[\fields][0][\in]
(~hwOutputs + ~serverConf[\pointsAmount])
~serverConf[\oscCtrlReady]
~points[0][\synthGain].set(\busIn, ~hwOutputs + 3);
~points[0][\synthGain].set(\gain, 1);
~hwOutputs + 3
{
	arg value = 1800;
	while {value > 180} { value = value - 360; value.postln; };
	while {value < 180} { value = value + 360; };
}
~outputs[0][\synthSend].get(\volume, {arg volume; volume.postln;});
~hwOut.size;
~outputs[1][\busIn];
~synthDecoderBin.get(\busOut, {arg volume; volume.postln;});
~outputs[0][\synthDelay].get(\delay, {arg volume; volume.postln;});
SampleDur.ir;
1 / ~serverConf[\sampleRate] * 4;
100.0.clip((SampleDur.ir * 4).asFloat,10.0);
~buses[\points][0][\in]
Quarks.install("https://github.com/shimpe/sfz");

(// SFZ Example
o = Server.local.options;
o.numBuffers_(16000);
o.memSize_(8192*100);
s.reboot;
s.waitForBoot({
    ~test = SfzReader();
    //~test.load(s, "/home/shimpe/documents/music/soundfonts/vpo/Virtual-Playing-Orchestra3/Woodwinds/flute-SOLO-sustain.sfz");
    //~test.load(s, "/home/shimpe/documents/music/soundfonts/salamanderpiano/SalamanderGrandPianoV3_44.1khz16bit/SalamanderGrandPianoV3.sfz");
    //~test.load(s, "/home/shimpe/documents/music/soundfonts/nobudget/sfz/melodica/Melodica/melodica.sfz");
    //~test.load(s, "/home/shimpe/documents/music/soundfonts/nobudget/sfz/60s_organ/Farfisa/60s_organ.sfz");
    //~test.load(s, "/home/shimpe/documents/music/soundfonts/nobudget/sfz/acousbass/AcousBass/acous_bass.sfz");
    ~test.load(s, "/home/shimpe/documents/music/soundfonts/nobudget/sfz/altosax/AltoSax/altosax.sfz");
    fork {
        // play some normal notes
        Panola("a1_8 b1 g1 c2 f1 g1 a1_4").midinotePattern.asStream.all.do({
            |note|
            ~test.play(out:0, freq:note.midicps, amp:0.4, dur:2.0, legato:1.0);
            "next".postln;
            2.0.wait;
        });

        // some microtones
        [440,550,660,770,880,990].mirror2.mirror2.do({
            |freq, idx|
            ~test.play(out:0, freq:freq, amp:(0.4 + ((0.6/25)*idx)).debug("amp"), dur:2.0, legato:1.0);
            2.0.wait;
        });

        5.wait;

        ~test.freeMemory;
    }

});
)

(
var myPath;
myPath = PathName.new("C:\\meganz\\dlsp\\work");
myPath.folders.postln;
)
















