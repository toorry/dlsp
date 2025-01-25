//// VARIABLES

~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);


//// DLSP SETTINGS

~dlspSettings = Dictionary.new();
~dlspSettings.put(\type, "dlspSettings");
~dlspSettings.put(\dlspSettingsVersion, "0.1");
~dlspSettings.put(\sourcesPath, ~path +/+ "work" +/+ "sources");
~dlspSettings.put(\serverAutoStart, false);

if (File.exists(~path +/+ "settings.dlspcfg")) {
	"DLSP settings file exists".postln;
	~dlspSettingsLoaded = JSONlib.parseFile(~path +/+ "settings.dlspcfg");

	"Updating settings from file".postln;
	try {

		~dlspSettingsLoaded.keys.do ({
			arg key;
			switch(key,
				\sourcesPath, {
					~dlspSettings[\sourcesPath] = ~dlspSettingsLoaded[key];
					("sourcesPath " ++ ~dlspSettingsLoaded[key]).postln;
				},
				\serverAutoStart, {
					~dlspSettings[\serverAutoStart] = ~dlspSettingsLoaded[key];
					("serverAutoStart " ++ ~dlspSettingsLoaded[key]).postln;
				}
			);
		});

	} { |error|
		//
	};
} {
	"DLSP settings file not exists".postln;
};

"Saving DLSP settings file".postln;
File.use(~path +/+ "settings.dlspcfg", "w", { |f|
		f.write(JSONlib.convertToJSON(~dlspSettings).postln);
	});

//// PREPARING FILE SOUND SOURCES ENVIRONMENT


//// FUNCTIONS

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

//// SOUND SERVER CONFIGURATION
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "server-config.scd").interpret.postln;
~serverConfig.value;

//// DEFAULT VALUES FOR PARAMETERS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "default-values.scd").interpret.postln;
~initDefaultValues.value;

//// SYNTH DEFINITIONS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "synth-defs.scd").interpret.postln;

//// BOOT SOUND SERVER AND INITIALIZE ENVIRONMENT
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "server-nt1.scd").interpret.postln;

//// SYNTH CONTROL FUNCTIONS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "synth-defs.scd").interpret.postln;

////SOUND SERVER STATE, CUES, SCENES AND SHOWS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "states.scd").interpret.postln;

////INITIALIZE DAEMONS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "daemons.scd").interpret.postln;

//// SYSTEM CONTROL OSC MESSAGES HANDLERS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "osc-system.scd").interpret.postln;

//// SERVER CONTROL OSC MESSAGES HANDLERS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "osc-server.scd").interpret.postln;

~initConfig.value;
