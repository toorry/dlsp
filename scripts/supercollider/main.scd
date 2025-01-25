//// VARIABLES

~dlspSettingsFile; //Default settings file
~dlspSettingsArray; //Array of strings containing "{parameter} {value}" pairs
~dlspSettings; //Dictionary containing {parameter} as keys and {value} as values

~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);


//// INITIALISE SETTINGS

~dlspSettings = Dictionary.new();
~dlspSettings.put(\type, "dlspSettings");
~dlspSettings.put(\dlspSettingsVersion, "0.1");
~dlspSettings.put(\sourcesPath, ~path +/+ "work" +/+ "sources");
~dlspSettings.put(\serverAutoStart, false);

if (File.exists(~path +/+ "settings.dlspcfg")) {
	"dlsp settings file exists".postln;
	~dlspSettings = JSONlib.parseFile(~path +/+ "settings.dlspcfg");
} {
	"dlsp settings file not exists".postln;
	File.use(~path +/+ "settings.dlspcfg", "w", { |f|
		f.write(JSONlib.convertToJSON(~dlspSettings).postln);
	});
};


//// PREPARING FILE SOUND SOURCES ENVIRONMENT


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

//// SOUND SERVER INITIALIZE
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "server-nt1.scd").interpret.postln;

//// SYSTEM OSC MESSAGES HANDLERS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "osc-system.scd").interpret.postln;

//// CONTROL OSC MESSAGES HANDLERS
File.readAllString(~path +/+ "scripts" +/+ "supercollider" +/+ "osc-control.scd").interpret.postln;

~initConfig.value;

//// FINDING CURRENT STATE FILE

~stateLoaded;

/*if (File.exists(~path +/+ "states" +/+ "current.dlspstate")) {
	"dlsp state file exists".postln;
	~stateLoaded = JSONlib.parseFile(~path +/+ "states" +/+ "current.dlspstate");
} {
	"dlsp state file not exists".postln;
	/*File.use(~path +/+ "settings.dlspcfg", "w", { |f|
		f.write(JSONlib.convertToJSON(~stateCurrent).postln);
	});*/
};*/