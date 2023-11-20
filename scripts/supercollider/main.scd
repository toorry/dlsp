//// VARIABLES

~dlspSettingsFile; //Default settings file
~dlspSettingsArray; //Array of strings containing "{parameter} {value}" pairs
~dlspSettings; //Dictionary containing {parameter} as keys and {value} as values

~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);



//// FINDING SETTINGS

if(File.exists(~path ++ "/settings.txt")) {
	'Settings file found'.postln;
} {
	'Settings file does not exist. Making one and configuring work folder..'.postln;
	if(File.exists(~path)) {} { File.mkdir(~path) };
	~dlspSettingsFile = File.new(~path ++ "/settings.txt", "w");
	~dlspSettingsFile.write("DestraLSP-settings-file format-v1.0\n");
	~dlspSettingsFile.write("work-path " ++ ~path ++ "/work\n");
	~dlspSettingsFile.write("osc-in-port 57120\n");
	~dlspSettingsFile.write("web-ui-port 8080\n");
	~dlspSettingsFile.close;
};

~dlspSettingsFile = File.open(~path ++ "/settings.txt", "r");
~dlspSettingsArray = ~dlspSettingsFile.readAllString.split($\n);
~dlspSettingsFile.close;

~dlspSettings = Dictionary.new();
~dlspSettingsArray.do ({
	arg item;
	var stringPair;
	stringPair = item.split($ );
	~dlspSettings.put(stringPair[0].asSymbol,stringPair[1]);
});

//// PREPARING FILE SOUND SOURCES ENVIRONMENT

if(File.exists(~dlspSettings['work-path'] ++ "/sources")) {
	'Sources found'.postln;
} {
	'Sources folder does not exist. Making one..'.postln;
	File.mkdir(~dlspSettings['work-path'] ++ "/sources");
};

////FUNCTIONS

~msgserverstart = {
	~ostagec.sendMsg('/dlsp/server/status', 1);
	~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Server started');
};
~msgserverstop = {
	~ostagec.sendMsg('/dlsp/server/status', 0);
	~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Server stopped');
};

//// ROUTINES
ServerBoot.add(~msgserverstart);
ServerQuit.add(~msgserverstop);

//// MIXER INITIALIZE
File.readAllString(~path ++ "/scripts/supercollider/mixer.scd").interpret;

//// SYSTEM OSC MESSAGES HANDLERS
File.readAllString(~path ++ "/scripts/supercollider/osc-system.scd").interpret;

~regularBoot = {

	~initConfig.value;
	~bootConfig.value(
		hwInputs: 2, hwOutputs: 2,
		//hwInDevice: "Windows WASAPI : Microphone Array (AMD Audio Device)",
		//hwInDevice: "Windows WASAPI : CABLE Output (VB-Audio Virtual Cable)",
		//hwOutDevice: "Windows WASAPI : Line (Realphones System-Wide)",
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
};

ServerBoot.add({ ~initKernels.value; s.sync; });
ServerBoot.add({ ~prepareSynths.value; s.sync; });
ServerBoot.add({ ~initBuses.value; s.sync; });
ServerBoot.add({ ~initChannels.value; s.sync; });
ServerBoot.add({ ~initGroups.value; s.sync; });
ServerBoot.add({ ~initSynths.value; s.sync; });
ServerBoot.add({ ~vuSend.play; s.sync; });