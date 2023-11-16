OSCFunc.trace(true);
OSCFunc.trace(false);
OSCFunc.free;


~ostagec = NetAddr.new("127.0.0.1", 8080);
~myoscaddr = NetAddr.new("127.0.0.1", 57120);

~ostagec.sendMsg('/ping', 11);

~msgserverstart = { ~ostagec.sendMsg('/dlsp/server/status', 1) };
~msgserverstop = { ~ostagec.sendMsg('/dlsp/server/status', 0) };

OSCdef(\test, {|msg, time, addr, recvPort| \unmatching.postln}, '/chat', ~ostagec);
OSCdef.newMatching(\test2, {|msg, time, addr, recvPort| \matching.postln}, '/chat*', ~ostagec);


OSCdef.freeAll;
s.boot;
s.quit;

n = NetAddr("127.0.0.1", 57120); // local machine

OSCdef(\test, {|msg, time, addr, recvPort| \unmatching.postln}, '/chat', n); // def style
OSCdef.newMatching(\test2, {|msg, time, addr, recvPort| \matching.postln}, '/chat', n); // path matching
OSCdef(\test3, {|msg, time, addr, recvPort| \oneShot.postln}, '/chat', n).oneShot; // once only


m = NetAddr("127.0.0.1", 57120); // loopback

m.sendMsg("/chat", "Hello App 1");
m.sendMsg("/chat", "Hello App 1"); // oneshot gone
m.sendMsg("/ch?t", "Hello App 1");
m.sendMsg("/*", "Hello App 1");
m.sendMsg("/chit", "Hello App 1"); // nothing
NetAddr.disconnectAll;

ServerBoot.add(~msgserverstart);
ServerQuit.add(~msgserverstop);

OnError

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