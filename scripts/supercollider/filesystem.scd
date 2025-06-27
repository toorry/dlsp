~fileList;
~fileListMsg;

~fileListDict = Dictionary();
~fileListDict.put(\folders, List.newClear());
~fileListDict.put(\files, List.newClear());

~filePath;

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

		~filePath = path +/+ ~fileList[num];

		File.type(~filePath).switch(
			\directory, { ~fileListDict[\folders].add(~fileList[num]) },
			\regular, { ~fileListDict[\files].add(~fileList[num]) }
		);
		//~fileList[num] = path +/+ ~fileList[num];
		//~fileList[num].postln;
	});

	~fileListMsg = ["/drawList", "source", "folder", ~fileListDict[\folders].size] ++ ~fileListDict[\folders].asArray;
	~fileListMsg = ["/drawList", "source", "file", ~fileListDict[\files].size] ++ ~fileListDict[\files].asArray;
	~ostagec.sendMsg(*~fileListMsg);
};