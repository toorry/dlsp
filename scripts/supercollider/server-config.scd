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
	~serverConf.put( \realTimeMemory, 1048576);
	~serverConf.put( \wireBuffersNumber, 128);

	~serverConf.put( \inputsMonoAmount, 4 );
	~serverConf.put( \inputsAmbAmount, 1 );
	~serverConf.put( \outputsAmount, 16 );

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