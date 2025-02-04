~sendDeviceList = {
	arg netAddr = ~ostagec;
	netAddr.sendMsg('/dlsp/log', Date.getDate.format("%Y-%m-%d %H:%M:%S") ++ ' Receiving device list');
	ServerOptions.devices.do ({
		arg item;
		netAddr.sendMsg('/dlsp/log', "    " ++ item);
	});
};

~serverConfig = {

	"Configuring sound server".postln;

	//~sendDeviceList.value;

	~serverConf = Dictionary.new();
	~serverConf.put(\defaultDevice, "ASIO : UMC ASIO Driver");
	~serverConf.put( \hardwareInputsAmount, 8 );
	~serverConf.put( \hardwareOutputsAmount, 10 );
	~serverConf.put( \sampleRate, 48000 );
	~serverConf.put(\minDelayC, 1 / ~serverConf[\sampleRate] * 4);
	~serverConf.put( \realTimeMemory, 1048576);
	~serverConf.put( \wireBuffersNumber, 128);

	~serverConf.put( \inputsAmount, 16 );
	~serverConf.put( \pointsAmount, 16 );
	~serverConf.put( \fieldsAmount, 4 );
	~serverConf.put( \outputsAmount, 18 );

	//UMC 1820
	~serverConf.put(\inPatch,[10,11,12,13,14,15,16,17]);
	~serverConf.put(\outPatch,[0,1,2,3,4,5,6,7,8,9]);

	//UMC 1820 + ADAT
	//~serverConf.put(\inPatch,[20,21,22,23,24,25,26,27,30,31,32,33,34,35,36,37]);
	//~serverConf.put(\outPatch,[0,1,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,19]);

	~serverConf.put( \ambOrder, 1 );
	~serverConf.put( \ambChansAmount, (~serverConf[\ambOrder] + 1).squared );

	~serverConf.put( \roomRadius, 7);

	~serverConf.put( \decoderMainType, "circle" );
	~serverConf.put( \decoderMainSpeakersAmount, 4 );
	~serverConf.put( \mainDirections, [30.0, 135.0, -135.0, -30.0].degrad );
	//~serverConf.put( \mainDirections, [30, 80, 120, 160, -160, -120, -80, -30].degrad );
	~serverConf.put( \hoaBeamShape, \basic );
	~serverConf.put( \hoaMatch, \amp );

	~serverConf.put(\saveStateRate, 5);

	~serverConf.put(\oscCtrlReady, false);
};