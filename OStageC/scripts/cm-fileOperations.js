//const statePath = './states_data.json'
//const states = loadJSON(statePath) || {}
var fs = nativeRequire('fs')
var path
var content

//Loading File
function loadFromFS(path) {

    return loadJSON(path)
}

//Saving File
function saveToFS(path,content) {

    let obj = JSON.parse(content);
    saveJSON(path, obj)
}

module.exports = {
    oscOutFilter: function(data) {
        var {host, port, address, args} = data

        //'If exists' check (address, path, sender id, callback object)
        if (address === '/dick') {
          console.log(`check task from "${args[1].value}"\nchecking path "${args[0].value}"`);
          try{
            let pathObj = args[0].value;
            var exists = false
            if(fs.existsSync(pathObj)){
              console.log(`${pathObj} exists`)
              exists = true
            } else {console.log(`not exists`)}
            receive('/fsexcheck', [exists,args[1],args[2]])
          } catch (e) {
            console.log(`error while checking path ${args[0].value}`)
            console.error(e)
          }
        }

        //Saving File (address, path, sender id, file)
        else if (address === '/stfs' && args.length === 3) {
            console.log(`filesystem task from "${args[1].value}"\nsaving to path ${args[0].value}`);
            try {
                saveToFS(args[0].value, args[2].value)
            } catch (e) {
                console.log('error while saving to '+args[0].value)
                console.error(e)
            }
            return
        }

        //Loading File (address, path, sender id, recipient id)
        else if (address === '/lffs' && args.length === 3) {
            console.log(`filesystem task from "${args[1].value}"\nloading from path "${args[0].value}"`)
            try {
              content = loadFromFS(args[0].value)
              args[1].type = 'senderId'
              args[2].type = 'recipientId'
              receive('/fileLoaded', [content,args[1],args[2]])
            } catch (e) {
              console.log('error while loading from '+args[0].value)
              console.error(e)
            }
            //console.log(content);
        }

        //Loading File (address, path, sender id, recipient id, options object)
        else if (address === '/lffs' && args.length === 4) {
            console.log(`filesystem task from "${args[1].value}"\nloading from path "${args[0].value}"`)
            console.log(`options ${args[3].value}`);
            try {
              content = loadFromFS(args[0].value)
              args[1].type = 'senderId'
              args[2].type = 'recipientId'
              receive('/fileLoaded', [content,args[1],args[2],args[3]])
            } catch (e) {
              console.log('error while loading from '+args[0].value)
              console.error(e)
            }
            //console.log(content);
        }

        //Creating Directory (address, path)
        else if (address === '/mkdir' && args.length === 1) {
          console.log(`checking directory "${args[0].value}"`);
          try{
            let pathObj = args[0].value;
            if(!fs.existsSync(pathObj)){
              fs.mkdirSync(pathObj,{recursive: true});
              console.log(`${pathObj} created`);
            } else {console.log(`exists`)}
          } catch (e) {
            console.log(`error while creating dir ${args[0].value}`)
            console.error(e)
          }
        }


        //return data
    }
}
