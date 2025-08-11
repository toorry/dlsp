~fileList;
~fileListMsg;
~fileMsg;

~fileListDict = Dictionary();
~fileListDict.put(\folders, List.newClear());
~fileListDict.put(\files, List.newClear());

~filePath;
~fileProps;
~fileAsSound;

~getFileList = {
	arg path;

	~os.switch(
		\mac,   {  },
		\lin,   {  },
		\win,   { ~fileList = ("dir /b " ++ path).unixCmdGetStdOut.asString.split($\n) }
	);

	~fileList.removeAt(~fileList.size-1);

	~fileListDict[\folders].clear;
	~fileListDict[\files].clear;

	(~fileList.size).do ({
		arg num;

		~fileProps = Dictionary();
		~filePath = path +/+ ~fileList[num];

		File.type(~filePath).switch(
			\directory, { ~fileListDict[\folders].add(~fileList[num]) },
			\regular, {

				~fileProps.put(\path, ~filePath);
				~fileAsSound = SoundFile.openRead(~filePath);
				if( ~fileAsSound == nil )
				{
					~fileProps.put(\isSound, false)
				} {
					~fileProps.put(\isSound, true);
					~fileProps.put(\channels, ~fileAsSound.numChannels);
					~fileProps.put(\duration, ~fileAsSound.duration);
					~fileProps.put(\type, ~fileAsSound.headerFormat);
				};

				~fileProps.put(\size, File.fileSize(~filePath)).postln;
				~fileListDict[\files].add(~fileProps);
			}
		);
		//~fileList[num] = path +/+ ~fileList[num];
		//~fileList[num].postln;
	});

	//~fileListMsg = ["/drawList", "source", "folder", ~fileListDict[\folders].size] ++ ~fileListDict[\folders].asArray;
	//~fileListMsg = ["/drawList", "source", "file", ~fileListDict[\files].size] ++ ~fileListDict[\files].asArray;
	//~ostagec.sendMsg(*~fileListMsg);
};

~sendFileProperties = {
	arg path, num;
	//
	"inSendFileProperties".postln;
	~fileProps = Dictionary();
	~filePath = path.postln;
	~fileProps.put(\path, ~filePath);
	~fileAsSound = SoundFile.openRead(~filePath);
	"beforeIF".postln;
	if( ~fileAsSound == nil )
	{
		~fileProps.put(\isSound, false)
	} {
		~fileProps.put(\isSound, true);
		~fileProps.put(\channels, ~fileAsSound.numChannels);
		~fileProps.put(\duration, ~fileAsSound.duration);
		~fileProps.put(\type, ~fileAsSound.headerFormat);
		~fileProps.put(\size, File.fileSize(~filePath));
	};

	~fileMsg = ["/fs", "s", "pr", num, ~fileProps[\isSound], ~fileProps[\channels], ~fileProps[\duration], ~fileProps[\type], ~fileProps[\size]];
	~ostagec.sendMsg(*~fileMsg);
};