~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);

~msgserverstart = { ~ostagec.sendMsg('/dlsp/server/status', 1) };
~msgserverstop = { ~ostagec.sendMsg('/dlsp/server/status', 0) };

ServerBoot.add(~msgserverstart);
ServerQuit.add(~msgserverstop);

OSCdef(\ping,
	{ arg msg;
		~ostagec.sendMsg('/dlsp/sclang/status', 1); },
	'/dlsp/ping');

OSCdef(\startServer,
	{ arg msg;
		\bootcommand.postln;
		s.boot; },
	'/dlsp/server/start');

OSCdef(\stopServer,
	{ arg msg;
		\stopcommand.postln;
		s.quit; },
	'/dlsp/server/stop');