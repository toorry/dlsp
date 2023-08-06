//const statePath = './states_data.json'
//const states = loadJSON(statePath) || {}
var fs = nativeRequire('fs')
var path = nativeRequire('path')
//var pathstring
var content

//Loading File
function loadFromFS(pathstring) {

    return loadJSON(pathstring)
}

//Saving File
function saveToFS(pathstring,content) {

    let obj = JSON.parse(content);
    saveJSON(pathstring, obj)
}

//Initialise session
function DlspInit(pathspocket) {
  try {
    var pathObj = JSON.parse(pathspocket)
    if (pathObj == null) {
      console.log(`dlsp. Paths object is incorrect (${pathObj})`)
      let pathstring = __dirname+'\\dlsppaths.dlspcfg'
      if (fs.existsSync(pathstring)) {
        pathObj = loadJSON(pathstring)
      } else {
        pathObj = Object.create({})
        pathObj.Type = 'Paths'
      }
    }
    if (pathObj.Type != 'Paths') {
      console.log(`dlsp. Paths object type is incorrect (${pathObj.Type})`)
      pathObj.Type = 'Paths'
    }

      if (typeof pathObj.Root != 'string') {
        console.log(`dlsp. Root paths is empty (${pathObj.Root})`)
        pathObj.Root = __dirname
      }
      if (!fs.existsSync(pathObj.Root)) {
        fs.mkdirSync(pathObj.Root,{recursive: true})
        console.log(`${pathObj.Root} created`)
      }
      receive('/txtPathsRoot',pathObj.Root)

      if (typeof pathObj.Settings != 'string') {
        console.log(`dlsp. Settings paths is empty (${pathObj.Settings})`)
        pathObj.Settings = __dirname+'\\settings'
      }
      if (!fs.existsSync(pathObj.Settings)) {
        fs.mkdirSync(pathObj.Settings,{recursive: true})
        console.log(`${pathObj.Settings} created`)
      }
      receive('/txtPathsSettings',pathObj.Settings)

      if (typeof pathObj.Scenes != 'string') {
        console.log(`dlsp. Scenes paths is empty (${pathObj.Scenes})`)
        pathObj.Scenes = __dirname+'\\scenes'
      }
      if (!fs.existsSync(pathObj.Scenes)) {
        fs.mkdirSync(pathObj.Scenes,{recursive: true})
        console.log(`${pathObj.Scenes} created`)
      }
      receive('/txtPathsScenes',pathObj.Scenes)

      if (typeof pathObj.PresetsInput != 'string') {
        console.log(`dlsp. Input Presets paths is empty (${pathObj.PresetsInput})`)
        pathObj.PresetsInput = __dirname+'\\presets\\input'
      }
      if (!fs.existsSync(pathObj.PresetsInput)) {
        fs.mkdirSync(pathObj.PresetsInput,{recursive: true})
        console.log(`${pathObj.PresetsInput} created`)
      }
      receive('/txtPathsPresetsInput',pathObj.PresetsInput)

      if (typeof pathObj.PresetsPoint != 'string') {
        console.log(`dlsp. Point Presets paths is empty (${pathObj.PresetsPoint})`)
        pathObj.PresetsPoint = __dirname+'\\presets\\point'
      }
      if (!fs.existsSync(pathObj.PresetsPoint)) {
        fs.mkdirSync(pathObj.PresetsPoint,{recursive: true})
        console.log(`${pathObj.PresetsPoint} created`)
      }
      receive('/txtPathsPresetsPoint',pathObj.PresetsPoint)

      if (typeof pathObj.PresetsOutputs != 'string') {
        console.log(`dlsp. Outputs Presets paths is empty (${pathObj.PresetsOutputs})`)
        pathObj.PresetsOutputs = __dirname+'\\presets\\outputs'
      }
      if (!fs.existsSync(pathObj.PresetsOutputs)) {
        fs.mkdirSync(pathObj.PresetsOutputs,{recursive: true})
        console.log(`${pathObj.PresetsOutputs} created`)
      }
      receive('/txtPathsPresetsOutputs',pathObj.PresetsOutputs)

      if (typeof pathObj.PresetsField != 'string') {
        console.log(`dlsp. Field Presets paths is empty (${pathObj.PresetsField})`)
        pathObj.PresetsField = __dirname+'\\presets\\field'
      }
      if (!fs.existsSync(pathObj.PresetsField)) {
        fs.mkdirSync(pathObj.PresetsField,{recursive: true})
        console.log(`${pathObj.PresetsField} created`)
      }
      receive('/txtPathsPresetsField',pathObj.PresetsField)

      if (typeof pathObj.PresetsGain != 'string') {
        console.log(`dlsp. Gain Presets paths is empty (${pathObj.PresetsGain})`)
        pathObj.PresetsGain = __dirname+'\\presets\\gain'
      }
      if (!fs.existsSync(pathObj.PresetsGain)) {
        fs.mkdirSync(pathObj.PresetsGain,{recursive: true})
        console.log(`${pathObj.PresetsGain} created`)
      }
      receive('/txtPathsPresetsGain',pathObj.PresetsGain)

      if (typeof pathObj.PresetsEQ != 'string') {
        console.log(`dlsp. EQ Presets paths is empty (${pathObj.PresetsEQ})`)
        pathObj.PresetsEQ = __dirname+'\\presets\\eq'
      }
      if (!fs.existsSync(pathObj.PresetsEQ)) {
        fs.mkdirSync(pathObj.PresetsEQ,{recursive: true})
        console.log(`${pathObj.PresetsEQ} created`)
      }
      receive('/txtPathsPresetsEQ',pathObj.PresetsEQ)

      if (typeof pathObj.PresetsGate != 'string') {
        console.log(`dlsp. Gate Presets paths is empty (${pathObj.PresetsGate})`)
        pathObj.PresetsGate = __dirname+'\\presets\\gate'
      }
      if (!fs.existsSync(pathObj.PresetsGate)) {
        fs.mkdirSync(pathObj.PresetsGate,{recursive: true})
        console.log(`${pathObj.PresetsGate} created`)
      }
      receive('/txtPathsPresetsGate',pathObj.PresetsGate)

      if (typeof pathObj.PresetsComp != 'string') {
        console.log(`dlsp. Comp Presets paths is empty (${pathObj.PresetsComp})`)
        pathObj.PresetsComp = __dirname+'\\presets\\comp'
      }
      if (!fs.existsSync(pathObj.PresetsComp)) {
        fs.mkdirSync(pathObj.PresetsComp,{recursive: true})
        console.log(`${pathObj.PresetsComp} created`)
      }
      receive('/txtPathsPresetsComp',pathObj.PresetsComp)

      if (typeof pathObj.PresetsLimiter != 'string') {
        console.log(`dlsp. Limiter Presets paths is empty (${pathObj.PresetsLimiter})`)
        pathObj.PresetsLimiter = __dirname+'\\presets\\limiter'
      }
      if (!fs.existsSync(pathObj.PresetsLimiter)) {
        fs.mkdirSync(pathObj.PresetsLimiter,{recursive: true})
        console.log(`${pathObj.PresetsLimiter} created`)
      }
      receive('/txtPathsPresetsLimiter',pathObj.PresetsLimiter)

      if (typeof pathObj.PresetsSends != 'string') {
        console.log(`dlsp. Sends Presets paths is empty (${pathObj.PresetsSends})`)
        pathObj.PresetsSends = __dirname+'\\presets\\sends'
      }
      if (!fs.existsSync(pathObj.PresetsSends)) {
        fs.mkdirSync(pathObj.PresetsSends,{recursive: true})
        console.log(`${pathObj.PresetsSends} created`)
      }
      receive('/txtPathsPresetsSends',pathObj.PresetsSends)

      if (typeof pathObj.PresetsHall != 'string') {
        console.log(`dlsp. Hall Presets paths is empty (${pathObj.PresetsHall})`)
        pathObj.PresetsHall = __dirname+'\\presets\\hall'
      }
      if (!fs.existsSync(pathObj.PresetsHall)) {
        fs.mkdirSync(pathObj.PresetsHall,{recursive: true})
        console.log(`${pathObj.PresetsHall} created`)
      }
      receive('/txtPathsPresetsHall',pathObj.PresetsHall)

      if (typeof pathObj.PresetsDelay != 'string') {
        console.log(`dlsp. Delay Presets paths is empty (${pathObj.PresetsDelay})`)
        pathObj.PresetsDelay = __dirname+'\\presets\\delay'
      }
      if (!fs.existsSync(pathObj.PresetsDelay)) {
        fs.mkdirSync(pathObj.PresetsDelay,{recursive: true})
        console.log(`${pathObj.PresetsDelay} created`)
      }
      receive('/txtPathsPresetsDelay',pathObj.PresetsDelay)

    saveJSON(__dirname+'\\dlsppaths.dlspcfg', pathObj)

  } catch(e) {
    console.log(`dlsp. error while initialising`)
    console.error(e)
  }
}


module.exports = {
    oscOutFilter: function(data) {
        var {host, port, address, args} = data

        //Initialise request (address, sender id, (opt) PathsFile path)
        if (address === '/dlsp/init') {
          switch(args.length) {
            case 2:
              console.log(`dlsp. Initialising task from '${args[0]}' with custom paths`)
              DlspInit(args[1])
              break
            case 1:
              console.log(`dlsp. Initialising task from '${args[0]}' with default paths`)
              DlspInit(null)
              break
            case 0:
              console.log(`dlsp. Initialising task with default paths`)
              DlspInit(null)
              break
            default:
          }
        }

        //'If exists' check (address, path, sender id)
        else if (address === '/ifex') {
          console.log(`check task from "${args[1].value}"\nchecking path "${args[0].value}"`);
          try{
            var pathstring = args[0].value;
            pathstring = __dirname+pathstring
            var exists = false
            if(fs.existsSync(pathstring)){
              console.log(`${pathstring} exists`)
              exists = true
            } else {console.log(`${pathstring} not exists`)}
            receive('/fsexcheck', [exists,args[1]])
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
            let pathstring = args[0].value;
            if(!fs.existsSync(pathstring)){
              fs.mkdirSync(pathstring,{recursive: true});
              console.log(`${pathstring} created`);
            } else {console.log(`exists`)}
          } catch (e) {
            console.log(`error while creating dir ${args[0].value}`)
            console.error(e)
          }
        }


        //return data
    }
}
