const statePath = './states_data.json'
const states = loadJSON(statePath) || {}

 function dloadState(name) {
   console.log(`in Load function`)
    if (name in states) {
        receive('/STATE/SET', states[name])
    } else {
        console.log(`state ${name} not found`)
    }
}

 function dsaveState(name, state) {
    states[name] = state
    saveJSON(statePath, states)
}

module.exports = {
    oscOutFilter: function(data) {
        var {host, port, address, args} = data

        if (address === '/state/save' && args.length === 2) {
            try {
                dsaveState(args[0].value, JSON.parse(args[1].value))
            } catch (e) {
                console.log(`error while saving state ${args[0].value}`)
                console.error(e)
            }
            return
        }

        else if (address === '/state/load') {
            dloadState(args[0].value)
            return
        }


        return data
    }
}
