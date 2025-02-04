
/// POINT

~setPointGain = {
	arg num, value, fb;

	~points[num][\synthGain].set(\gain, value);
	~points[num][\gain] = value;
	~stateCurrent[\points][num][\gain] = value;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "g", value); };
	("Point " ++ (num + 1) ++ " gain " ++ value).postln;
};

~setPointX = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	x = value;
	y = ~points[num][\Y];
	z = ~points[num][\Z];

	azim = atan( x.neg / y.abs );
	if ( y < 0 ) {
		if ( x > 0 ) { azim = azim + pi*2;};
		azim = pi - azim;
	};

	elev = atan( z / sqrt( squared(x) + squared(y) ) );

	dist = sqrt( squared(x) + squared(y) + squared(z) );

	~points[num][\X] = x;
	~points[num][\synthPan].set(\azim, azim);
	~points[num][\azim] = azim;
	~stateCurrent[\points][num][\azim] = azim;
	~points[num][\synthPan].set(\elev, elev);
	~points[num][\elev] = elev;
	~stateCurrent[\points][num][\elev] = elev;
	~points[num][\synthPan].set(
		\r, dist.clip(~defaultValues[\point][\distMin],~defaultValues[\point][\distMax]),
		\dist, dist.clip(~serverConf[\roomRadius],~defaultValues[\point][\distMax]));
	~points[num][\dist] = dist;
	~stateCurrent[\points][num][\dist] = dist;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " x " ++ x).postln;
};

~setPointY = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	x = ~points[num][\X];
	y = value;
	z = ~points[num][\Z];

	azim = atan( x.neg / y.abs );
	if ( y < 0 ) {
		if ( x > 0 ) { azim = azim + pi*2;};
		azim = pi - azim;
	};

	elev = atan( z / sqrt( squared(x) + squared(y) ) );

	dist = sqrt( squared(x) + squared(y) + squared(z) );

	~points[num][\Y] = y;
	~points[num][\synthPan].set(\azim, azim);
	~points[num][\azim] = azim;
	~stateCurrent[\points][num][\azim] = azim;
	~points[num][\synthPan].set(\elev, elev);
	~points[num][\elev] = elev;
	~stateCurrent[\points][num][\elev] = elev;
	~points[num][\synthPan].set(
		\r, dist.clip(~defaultValues[\point][\distMin],~defaultValues[\point][\distMax]),
		\d, dist.clip(~serverConf[\roomRadius],~defaultValues[\point][\distMax]));
	~points[num][\dist] = dist;
	~stateCurrent[\points][num][\dist] = dist;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " y " ++ y).postln;
};

~setPointZ = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	x = ~points[num][\X];
	y = ~points[num][\Y];
	z = value;

	elev = atan( z / sqrt( squared(x) + squared(y) ) );

	dist = sqrt( squared(x) + squared(y) + squared(z) );

	~points[num][\Z] = z;
	~points[num][\synthPan].set(\elev, elev);
	~points[num][\elev] = elev;
	~stateCurrent[\points][num][\elev] = elev;
	~points[num][\synthPan].set(
		\r, dist.clip(~defaultValues[\point][\distMin],~defaultValues[\point][\distMax]),
		\dist, dist.clip(~serverConf[\roomRadius],~defaultValues[\point][\distMax]));
	~points[num][\dist] = dist;
	~stateCurrent[\points][num][\dist] = dist;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " z " ++ z).postln;
};

~setPointAzim = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	azim = value.degrad;
	while {azim > pi} { azim = azim - pi*2; };
	while {azim < pi.neg} { azim = azim + pi*2; };
	~points[num][\synthPan].set(\azim, azim);
	~points[num][\azim] = azim;
	~stateCurrent[\points][num][\azim] = azim;

	elev = ~points[num][\elev];
	dist = ~points[num][\dist];

	x = neg(dist*cos(elev)*sin(azim));
	y = dist*cos(elev)*cos(azim);
	z = ~points[num][\Z];

	~points[num][\X] = x;
	~points[num][\Y] = y;

	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " azim " ++ azim.raddeg).postln;
};

~setPointElev = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	elev = value.degrad;
	while { elev > pi/2 } { elev = pi*2; };
	while { azim < (pi/2).neg } { elev = (pi*2).neg; };
	~points[num][\synthPan].set(\elev, elev);
	~points[num][\elev] = elev;
	~stateCurrent[\points][num][\elev] = elev;

	azim = ~points[num][\azim];
	dist = ~points[num][\dist];

	x = neg(dist*cos(elev)*sin(azim));
	y = dist*cos(elev)*cos(azim);
	z = dist*sin(elev);

	~points[num][\X] = x;
	~points[num][\Y] = y;
	~points[num][\Z] = z;

	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " elev " ++ elev.raddeg).postln;
};

~setPointDist = {
	arg num, value, fb;
	var x, y, z, azim, elev, dist;

	dist = value;
	~points[num][\synthPan].set(
		\r, dist.clip(~defaultValues[\point][\distMin],~defaultValues[\point][\distMax]),
		\dist, dist.clip(~serverConf[\roomRadius],~defaultValues[\point][\distMax]));
	~points[num][\dist] = dist;
	~stateCurrent[\points][num][\dist] = dist;

	azim = ~points[num][\azim];
	elev = ~points[num][\elev];

	x = neg(dist*cos(elev)*sin(azim));
	y = dist*cos(elev)*cos(azim);
	z = dist*sin(elev);

	~points[num][\X] = x;
	~points[num][\Y] = y;
	~points[num][\Z] = z;

	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " dist " ++ dist).postln;
};

~setPointPan = {
	arg num, x, y, z, azim, elev, dist, fb;

	azim = azim.degrad;
	elev = elev.degrad;
	~points[num][\synthPan].set(\azim, azim);
	~points[num][\azim] = azim;
	~stateCurrent[\points][num][\azim] = azim;
	~points[num][\synthPan].set(\elev, elev);
	~points[num][\elev] = elev;
	~stateCurrent[\points][num][\elev] = elev;
	~points[num][\synthPan].set(
		\r, dist.clip(~defaultValues[\point][\distMin],~defaultValues[\point][\distMax]),
		\dist, dist.clip(~serverConf[\roomRadius],~defaultValues[\point][\distMax]));
	~points[num][\dist] = dist;
	~stateCurrent[\points][num][\dist] = dist;
	~points[num][\X] = x;
	~points[num][\Y] = y;
	~points[num][\Z] = z;

	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "pan", x, y, z, azim.raddeg, elev.raddeg, dist); };
	("Point " ++ (num + 1) ++ " pan").postln;
};

~setPointMute = {
	arg num, value, fb;
	~points[num][\synthPan].set(\mute, value);
	~points[num][\mute] = value;
	~stateCurrent[\points][num][\mute] = value;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "m", value); };
	("Point " ++ (num + 1) ++ " mute " ++ value).postln;
};

~setPointVolume = {
	arg num, value, fb;
	~points[num][\synthSend].set(\volume, value);
	~points[num][\volume] = value;
	~stateCurrent[\points][num][\volume] = value;
	if (fb) { ~ostagec.sendMsg("/fb", "p", num + 1, "v", value); };
	("Point " ++ (num + 1) ++ " volume " ++ value).postln;
};

~setPointPatchIn = {
	arg num, value, fb;
	if (value == -1) {
		~points[num][\synthGain].set(\busIn, ~busSilent);
	} {
		~points[num][\synthGain].set(\busIn, ~hwOutputs + value);
	};
	if (fb) { };
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


/// OUTPUT

~setOutputDelay = {
	arg num, value, fb;
	var delay = value / 1000;
	~outputs[num][\synthDelay].set(\delay, delay.clip(~serverConf[\minDelayC],10));
	~outputs[num][\delay] = delay;
	~stateCurrent[\outputs][num][\delay] = delay;
	if (fb) { ~ostagec.sendMsg("/fb", "o", num + 1, "d", delay); };
	("Output " ++ (num + 1) ++ " delay " ++ delay).postln;
};

~setOutputMute = {
	arg num, value, fb;
	~outputs[num][\synthSend].set(\mute, value);
	~outputs[num][\mute] = value;
	~stateCurrent[\outputs][num][\mute] = value;
	if (fb) { ~ostagec.sendMsg("/fb", "o", num + 1, "m", value); };
	("Output " ++ (num + 1) ++ " mute " ++ value).postln;
};

~setOutputVolume = {
	arg num, value, fb;
	~outputs[num][\synthSend].set(\volume, value);
	~outputs[num][\volume] = value;
	~stateCurrent[\outputs][num][\volume] = value;
	if (fb) { ~ostagec.sendMsg("/fb", "o", num + 1, "v", value); };
	("Output " ++ (num + 1) ++ " volume " ++ value).postln;
};