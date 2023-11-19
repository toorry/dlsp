~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);

~msgserverstart = {
	~ostagec.sendMsg('/dlsp/server/status', 1);
	~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Server started');
};
~msgserverstop = {
	~ostagec.sendMsg('/dlsp/server/status', 0);
	~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Server stopped');
};

ServerBoot.add(~msgserverstart);
ServerQuit.add(~msgserverstop);

OSCdef(\ping,
	{ arg msg;
		~ostagec.sendMsg('/dlsp/sclang/status', 1);
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' system status OK');
	},
	'/dlsp/ping');

OSCdef(\startServer,
	{ arg msg;
		'ostagec msg to boot server'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Booting sound server..');
		s.boot; },
	'/dlsp/server/start');

OSCdef(\stopServer,
	{ arg msg;
		'ostagec msg to quit server'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Quitting sound server..');
		s.quit; },
	'/dlsp/server/stop');

OSCdef(\reboot,
	{ arg msg;
		'ostagec msg to reboot system'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Rebooting..');
		"systemctl reboot -i".unixCmd; },
	'/dlsp/reboot');

OSCdef(\shutdown,
	{ arg msg;
		'ostagec msg to shutdown system'.postln;
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Shutting down..');
		"systemctl poweroff -i".unixCmd; },
	'/dlsp/shutdown');