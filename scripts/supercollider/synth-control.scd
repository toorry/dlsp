~setPointGain = {
	arg num, value;
	~points[num][\synthGain].set(\gain, value);
	~points[num][\gain] = value;
	~stateCurrent[\points][num][\gain] = value;
	("Point " ++ num ++ " gain " ++ value).postln;
};

~setPointAzim = {
	arg num, value;
	while {value > 180} { value = value - 360; };
	while {value < 180} { value = value + 360; };
	~points[num][\synthPan].set(\azimuth, value);
	~points[num][\azim] = value;
	~stateCurrent[\points][num][\azim] = value;
	("Point " ++ num ++ " azim " ++ value).postln;
};

~setPointElev = {
	arg num, value;
	~points[num][\synthPan].set(\elevation, value);
	~points[num][\elev] = value;
	~stateCurrent[\points][num][\elev] = value;
	("Point " ++ num ++ " elev " ++ value).postln;
};

~setPointDist = {
	arg num, value;
	~points[num][\synthPan].set(
		\radius, value.clip(0.1,1000),
		\distance, value.clip(~serverConf[\roomRadius],1000));
	~points[num][\dist] = value;
	~stateCurrent[\points][num][\dist] = value;
	("Point " ++ num ++ " dist " ++ value).postln;
};

~setPointMute = {
	arg num, value;
	~points[num][\synthPan].set(\mute, value);
	~points[num][\mute] = value;
	~stateCurrent[\points][num][\mute] = value;
	("Point " ++ num ++ " mute " ++ value).postln;
};

~setPointVolume = {
	arg num, value;
	~points[num][\synthSend].set(\volume, value);
	~points[num][\volume] = value;
	~stateCurrent[\points][num][\volume] = value;
	("Point " ++ num ++ " volume " ++ value).postln;
};
