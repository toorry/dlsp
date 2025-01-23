//// VARIABLES

~dlspSettingsFile; //Default settings file
~dlspSettingsArray; //Array of strings containing "{parameter} {value}" pairs
~dlspSettings; //Dictionary containing {parameter} as keys and {value} as values

~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);


//// FINDING SETTINGS


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
File.readAllString(~path ++ "/scripts/supercollider/server-nt1.scd").interpret.postln;

//// SYSTEM OSC MESSAGES HANDLERS
File.readAllString(~path ++ "/scripts/supercollider/osc-system.scd").interpret.postln;

//// CONTROL OSC MESSAGES HANDLERS
File.readAllString(~path ++ "/scripts/supercollider/osc-control.scd").interpret.postln;

~initConfig.value;