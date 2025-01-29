
/// POINT

~setPointGain = {
	arg num, value;
	~points[num][\synthGain].set(\gain, value);
	~points[num][\gain] = value;
	~stateCurrent[\points][num][\gain] = value;
	~ostagec.sendMsg("/fb", "ch", "p", num + 1, "g", value);
	("Point " ++ (num + 1) ++ " gain " ++ value).postln;
};

~setPointAzim = {
	arg num, value;
	while {value > 180} { value = value - 360; };
	while {value < 180} { value = value + 360; };
	~points[num][\synthPan].set(\azimuth, value);
	~points[num][\azim] = value;
	~stateCurrent[\points][num][\azim] = value;
	("Point " ++ (num + 1) ++ " azim " ++ value).postln;
};

~setPointElev = {
	arg num, value;
	~points[num][\synthPan].set(\elevation, value);
	~points[num][\elev] = value;
	~stateCurrent[\points][num][\elev] = value;
	("Point " ++ (num + 1) ++ " elev " ++ value).postln;
};

~setPointDist = {
	arg num, value;
	~points[num][\synthPan].set(
		\radius, value.clip(0.1,1000),
		\distance, value.clip(~serverConf[\roomRadius],1000));
	~points[num][\dist] = value;
	~stateCurrent[\points][num][\dist] = value;
	("Point " ++ (num + 1) ++ " dist " ++ value).postln;
};

~setPointMute = {
	arg num, value;
	~points[num][\synthPan].set(\mute, value);
	~points[num][\mute] = value;
	~stateCurrent[\points][num][\mute] = value;
	("Point " ++ (num + 1) ++ " mute " ++ value).postln;
};

~setPointVolume = {
	arg num, value;
	~points[num][\synthSend].set(\volume, value);
	~points[num][\volume] = value;
	~stateCurrent[\points][num][\volume] = value;
	("Point " ++ (num + 1) ++ " volume " ++ value).postln;
};

~setPointPatchIn = {
	arg num, value;
	if (value == -1) {
		~points[num][\synthGain].set(\busIn, ~busSilent);
	} {
		~points[num][\synthGain].set(\busIn, ~hwOutputs + value);
	};
	("Point " ++ (num + 1) ++ " patch " ++ value).postln;
};


/// FIELD

~setFieldGain = {
	arg num, value;
	~fields[num][\synthGain].set(\gain, value);
	~fields[num][\gain] = value;
	~stateCurrent[\fields][num][\gain] = value;
	("Field " ++ (num + 1) ++ " gain " ++ value).postln;
};

~setFieldRotate = {
	arg num, value;
	~fields[num][\synthTransform].set(\rotate, value);
	~fields[num][\rotate] = value;
	~stateCurrent[\fields][num][\rotate] = value;
	("Field " ++ (num + 1) ++ " rotate " ++ value).postln;
};

~setFieldTilt = {
	arg num, value;
	~fields[num][\synthTransform].set(\tilt, value);
	~fields[num][\tilt] = value;
	~stateCurrent[\fields][num][\tilt] = value;
	("Field " ++ (num + 1) ++ " tilt " ++ value).postln;
};

~setFieldTumble = {
	arg num, value;
	~fields[num][\synthTransform].set(\tumble, value);
	~fields[num][\tumb] = value;
	~stateCurrent[\fields][num][\tumb] = value;
	("Field " ++ (num + 1) ++ " tumb " ++ value).postln;
};

~setFieldZoomActive = {
	arg num, value;
	if (value.asBoolean) {
		~fields[num][\synthTransform].set(\busOut, ~fields[num][\busTransform]);
		~fields[num][\synthZoom].run(true);
	}
	{
		~fields[num][\synthZoom].run(false);
		~fields[num][\synthTransform].set(\busOut, ~fields[num][\busZoom]);
	};
	("Field " ++ (num + 1) ++ " zoom active " ++ value).postln;
};

~setFieldZoomAzim = {
	arg num, value;
	~fields[num][\synthZoom].set(\azim, value);
	~fields[num][\zoom][\azim] = value;
	~stateCurrent[\fields][num][\zoom][\azim] = value;
	("Field " ++ (num + 1) ++ " zoom azim " ++ value).postln;
};

~setFieldZoomElev = {
	arg num, value;
	~fields[num][\synthZoom].set(\elev, value);
	~fields[num][\zoom][\elev] = value;
	~stateCurrent[\fields][num][\zoom][\elev] = value;
	("Field " ++ (num + 1) ++ " zoom elev " ++ value).postln;
};

~setFieldZoomAngle = {
	arg num, value;
	~fields[num][\synthZoom].set(\angle, value.clip(-89.9,89.9));
	~fields[num][\zoom][\angle] = value;
	~stateCurrent[\fields][num][\zoom][\angle] = value;
	("Field " ++ (num + 1) ++ " zoom angle " ++ value).postln;
};

~setFieldZoomDist = {
	arg num, value;
	~fields[num][\synthZoom].set(\dist, value);
	~fields[num][\zoom][\dist] = value;
	~stateCurrent[\fields][num][\zoom][\dist] = value;
	("Field " ++ (num + 1) ++ " zoom dist " ++ value).postln;
};

~setFieldMute = {
	arg num, value;
	~fields[num][\synthSend].set(\mute, value);
	~fields[num][\mute] = value;
	~stateCurrent[\fields][num][\mute] = value;
	("Field " ++ (num + 1) ++ " mute " ++ value).postln;
};

~setFieldVolume = {
	arg num, value;
	~fields[num][\synthSend].set(\volume, value);
	~fields[num][\volume] = value;
	~stateCurrent[\fields][num][\volume] = value;
	("Field " ++ (num + 1) ++ " volume " ++ value).postln;
};

~setFieldPatchIn = {
	arg num, value;
	if (value == -1) {
		~fields[num][\synthGain].set(\busIn, ~busSilentAmb);
	} {
		~fields[num][\synthGain].set(\busIn, ~hwOutputs + value);
	};
	("Field " ++ (num + 1) ++ " patch " ++ value).postln;
};