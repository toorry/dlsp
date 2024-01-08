OSCdef(\ctrlInVol,
	{ arg msg;
		var inputNum = msg[1],
		volume = msg[2];
		~ostagec.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") + ' Shutting down..');
		"systemctl poweroff -i".unixCmd; },
	'/in/vol');