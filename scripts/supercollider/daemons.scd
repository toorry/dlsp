~initVM = {
	~vm = Dictionary.new();
	~vmOpt = Dictionary.new();
	~vmBuff = Dictionary.new();

	~vmOpt.put(\rate, 0.3);
	~vmOpt.put(\packMaxSize, 16);

	~vmBuff.put(\ambBuffer, Array.newClear(~serverConf[\ambChansAmount]));
	~vmBuff.put(\msg, Array.newClear(1));

	~vm.put(\inputsMono, Dictionary.new());  //Inputs MONO
	~vm.put(\inputsAmb, Dictionary.new());  //Inputs AMBISONIC
	~vm.put(\outputs, Dictionary.new()); //Outputs

	~vm[\inputsMono].put(\in, List.newUsing([1,2,3,4]));
	~vm[\inputsMono].put(\gain, List.newUsing([1,2,3,4]));
	~vm[\inputsMono].put(\out, List.newUsing([1,2]));

	~vm[\inputsAmb].put(\in, List.newClear());
	~vm[\inputsAmb].put(\out, List.newClear());

	~vm[\outputs].put(\in, List.newClear());

	~vm.postln;
};

~vmSend = Routine {
	var value;
	"vmSend".postln;
	loop {
		//"vm".postln;
		~vm.keys.do ({
			arg chanType;
			//(' '++chanType).postln;
			~vm[chanType].keys.do ({
				arg busType;
				//('  '++busType).postln;
				~vm[chanType][busType].do ({
					arg value;
					//(value + " ").post;
					(
						switch (busType,
							\in, {//INPUT BUS
								~ostagec.sendMsg("/v", "i", "in", value,
									~buses[\inputsMono][value-1][\inCtrl].getSynchronous.abs);
							},
							\gain, {//GAIN BUS
								~ostagec.sendMsg("/v", "i", "gn", value,
									~buses[\inputsMono][value-1][\gainCtrl].getSynchronous.abs);
							},
							\out, {//OUT BUS
								~vmBuff[\msg] = ["/v", "i", "ot", value] ++
								~buses[\inputsMono][value-1][\outCtrl].getnSynchronous(4).abs;
								~ostagec.sendMsg(*~vmBuff[\msg]);
							}
						);
					)
				});
			});
		});
		~vmOpt[\rate].wait;
	};
};