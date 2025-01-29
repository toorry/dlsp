// Do whatever you want
// initialize variables
// declare functions
// load modules
// etc

//var fs = nativeRequire('fs')

var selfAddress = '127.0.0.1:8080';

function CreateChannels( channelType, channelsAmount, channelsOnPage, pagesInGroup ) {

    var singularName = '';
    var pluralName = '';

    switch (channelType) {
        case 'input':
        console.log('CM Creating Inputs..');
        singularName = 'Input';
        pluralName = 'Inputs';
        break;
    
        case 'mix':
        console.log('CM Creating Mixes..');
        singularName = 'Mix';
        pluralName = 'Mixes';
        break;

        case 'point':
        console.log('CM Creating Points..');
        singularName = 'Point';
        pluralName = 'Points';
        break;
        
        default:
        console.log('CM Default name');
        break;
    }

    var pagesAmount = Math.ceil(channelsAmount / channelsOnPage);
    var groupsAmount = Math.ceil(pagesAmount / pagesInGroup);
    var groupsLevels = Math.ceil( Math.log(groupsAmount) / Math.log(pagesInGroup) );
    console.log(`CM ${pluralName} groupsLevels=${groupsLevels}`);
    let topLevelGroupsCount = Math.ceil( pagesAmount / Math.pow( pagesInGroup, groupsLevels ) );
    //if ( topLevelGroupsCount == 1 ) { groupsLevels-- };
    receive(`/varUI${pluralName}GroupsLevels`, groupsLevels);
    receive(`/varUI${pluralName}GroupsAmount`, groupsAmount);

    console.log(`CM ${pluralName} groupsAmount=${groupsAmount} pagesInGroup=${pagesInGroup}`);

    //Create Variables for Channels
    let typeFolderWidgets = [];

    console.log(`CM creating ${singularName} vars`);
    for ( let channelNum = 1; channelNum <= channelsAmount; channelNum++ ) {
      
      let channelFolder = {

        type: 'folder',
        id: `fldr${singularName}${channelNum}`,
        widgets: []
      };

      switch (channelType) {

        case 'input':

          //GAIN
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Gain`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}Gain`,
            //osc
            decimals: 6,
            bypass: true,
            //scripting
            onValue: `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'ga', value);\n` +
            `console.log(\`input${channelNum} gain \${value}\`);`
          });

          //X
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}X`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}X`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `var r = get('varInput${channelNum}EncR');\n` +
              `var x = value;\n` +
              `var y = get('varInput${channelNum}Y');\n` +
              `var z = get('varInput${channelNum}Z') * r;\n\n` +
              
              `console.log(\`input${channelNum} x \${x}\`);\n\n` +
              
              `var azim = Math.atan(-x/Math.abs(y))*180/Math.PI;\n` +
              `if(y<0) {\n` +
              `  if(x>0) {azim = azim+360;}\n` +
              `  azim = 180-azim;\n` +
              `}\n` +
              `set('varInput${channelNum}Azim',azim, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}},'az', azim);\n\n` +
              
              `var elev = Math.atan(z/Math.sqrt(Math.pow(x,2) + Math.pow(y,2)))*180/Math.PI;\n` +
              `set('varInput${channelNum}Elev',elev, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'el', elev);\n\n` +
              
              `var dist = Math.sqrt(Math.pow(x,2) + Math.pow(y,2) + Math.pow(z,2));\n` +
              `set('varInput${channelNum}Dist',dist, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', dist);\n\n` +
              
              `set('varInput${channelNum}XY',[x / r, y / r], {script: false});\n\n` +
              
              `set('varInput${channelNum}DistRelative', dist / r, {script: false});`
          });

          //Y
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Y`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}Y`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `var r = get('varInput${channelNum}EncR');\n` +
              `var x = get('varInput${channelNum}X');\n` +
              `var y = value;\n` +
              `var z = get('varInput${channelNum}Z') * r;\n\n` +

              `console.log(\`input${channelNum} y \${y}\`);\n\n` +

              `var azim = Math.atan(-x/Math.abs(y))*180/Math.PI;\n` +
              `if(y<0) {\n` +
              `  if(x>0) {azim = azim+360;}\n` +
              `  azim = 180-azim;\n` +
              `}\n` +
              `set('varInput${channelNum}Azim',azim, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'az', azim);\n\n` +

              `var elev = Math.atan(z/Math.sqrt(Math.pow(x,2) + Math.pow(y,2)))*180/Math.PI;\n` +
              `set('varInput${channelNum}Elev',elev, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'el', elev);\n\n` +

              `var dist = Math.sqrt(Math.pow(x,2) + Math.pow(y,2) + Math.pow(z,2));\n` +
              `set('varInput${channelNum}Dist',dist, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', dist);\n\n` +

              `set('varInput${channelNum}XY',[x / r, y / r], {script: false});\n\n` +

              `set('varInput${channelNum}DistRelative', dist / r, {script: false});\n`
          });

          //XY
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}XY`,
            //value
            default: [ 0, 1 ],
            linkId: `${singularName}${channelNum}XY`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `var r = get('varInput${channelNum}EncR');\n` +
              `var x = value[0] * r;\n` +
              `var y = value[1] * r;\n` +
              `var z = get('varInput${channelNum}Z') * r;\n\n` +
              
              `set('varInput${channelNum}X', x, {script: false});\n` +
              `set('varInput${channelNum}Y', y, {script: false});\n\n` +
              
              `console.log(\`input${channelNum} xy \${[value]}\`);\n\n` +
              
              `var azim = Math.atan(-x/Math.abs(y))*180/Math.PI;\n` +
              `if(y<0) {\n` +
              `  if(x>0) {azim = azim+360;}\n` +
              `  azim = 180-azim;\n` +
              `}\n` +
              `set('varInput${channelNum}Azim',azim, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'az', azim);\n\n` +
              
              `var elev = Math.atan(z/Math.sqrt(Math.pow(x,2) + Math.pow(y,2)))*180/Math.PI;\n` +
              `set('varInput${channelNum}Elev',elev, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'el', elev);\n\n` +
              
              `var dist = Math.sqrt(Math.pow(x,2) + Math.pow(y,2) + Math.pow(z,2));\n` +
              `set('varInput${channelNum}Dist',dist, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', dist);\n\n` +
              
              `set('varInput${channelNum}DistRelative', dist / r, {script: false});\n`
          });

          //Z
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Z`,
            //value
            default: 0,
            linkId: `${singularName}${channelNum}Z`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `var r = get('varInput${channelNum}EncR');\n` +
              `var x = get('varInput${channelNum}X');\n` +
              `var y = get('varInput${channelNum}Y');\n` +
              `var z = value * r;\n\n` +

              `console.log(\`input${channelNum} z \${z}\`);\n\n` +

              `var elev = Math.atan(z/Math.sqrt(Math.pow(x,2) + Math.pow(y,2)))*180/Math.PI;\n` +
              `set('varInput${channelNum}Elev',elev, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'el', elev);\n\n` +

              `var dist = Math.sqrt(Math.pow(x,2) + Math.pow(y,2) + Math.pow(z,2));\n` +
              `set('varInput${channelNum}Dist',dist, {script: false});\n` +
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', dist);\n\n` +

              `set('varInput${channelNum}DistRelative', dist / r, {script: false});`
          });

          //AZIM
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Azim`,
            //value
            default: 0,
            linkId: `${singularName}${channelNum}Azim`,
            //osc
            decimals: 1,
            bypass: true,
            //scripting
            onValue:
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'az', value);\n\n` +

              `console.log(\`input${channelNum} azim \${value}\`);\n\n` +

              `var azim = value;\n` +
              `var elev = get('varInput${channelNum}Elev');\n` +
              `var dist = get('varInput${channelNum}Dist'); \n` +
              `var r = get('varInput${channelNum}EncR');\n\n` +

              `var x,y,z;\n\n` +

              `x = -dist*Math.cos(elev*Math.PI/180)*Math.sin(azim*Math.PI/180);\n` +
              `y = dist*Math.cos(elev*Math.PI/180)*Math.cos(azim*Math.PI/180);\n` +
              `z = dist*Math.sin(elev*Math.PI/180);\n\n` +

              `set('varInput${channelNum}X',x, {script: false});\n` +
              `set('varInput${channelNum}Y',y, {script: false});\n` +
              `set('varInput${channelNum}Z', z/r, {script: false});\n` +
              `set('varInput${channelNum}XY', [x / r, y / r], {script: false});\n\n` +

              `set('varInput$${channelNum}DistRelative', dist / r, {script: false});`
          });

          //ELEV
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Elev`,
            //value
            default: 0,
            linkId: `${singularName}${channelNum}Elev`,
            //osc
            decimals: 1,
            bypass: true,
            //scripting
            onValue:
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'el', value);\n\n` +

              `console.log(\`inpu${channelNum} elev \${value}\`);\n\n` +

              `var azim = get('varInput${channelNum}Azim');\n` +
              `var elev = value;\n` +
              `var dist = get('varInput${channelNum}Dist');\n` +
              `var r = get('varInput${channelNum}EncR');\n\n` +

              `var x,y,z;\n\n` +

              `x = -dist*Math.cos(elev*Math.PI/180)*Math.sin(azim*Math.PI/180);\n` +
              `y = dist*Math.cos(elev*Math.PI/180)*Math.cos(azim*Math.PI/180);\n` +
              `z = dist*Math.sin(elev*Math.PI/180);\n\n` +

              `set('varInput${channelNum}X', x, {script: false});\n` +
              `set('varInput${channelNum}Y', y, {script: false});\n` +
              `set('varInput${channelNum}Z', z/r, {script: false});\n` +
              `set('varInput${channelNum}XY', [x/r,y/r], {script: false});\n\n` +

              `set('varInput${channelNum}DistRelative', dist / r, {script: false});`
          });

          //DIST
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Dist`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}Dist`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', value);\n\n` +

              `console.log(\`input${channelNum} dist \${value}\`);\n\n` +

              `var azim = get('varInput${channelNum}Azim');\n` +
              `var elev = get('varInput${channelNum}Elev');\n` +
              `var dist = value;\n` +
              `var r = get('varInput${channelNum}EncR');\n\n` +

              `var x,y,z;\n\n` +

              `x = -dist*Math.cos(elev*Math.PI/180)*Math.sin(azim*Math.PI/180);\n` +
              `y = dist*Math.cos(elev*Math.PI/180)*Math.cos(azim*Math.PI/180);\n` +
              `z = dist*Math.sin(elev*Math.PI/180);\n\n` +

              `set('varInput${channelNum}X',x, {script: false});\n` +
              `set('varInput${channelNum}Y', y, {script: false});\n` +
              `set('varInput${channelNum}Z', z/r, {script: false});\n` +
              `set('varInput${channelNum}XY', [x/r,y/r], {script: false});\n\n` +

              `set('varInput${channelNum}DistRelative', dist / r, {script: false});`
          });

          //DIST RELATIVE
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}DistRelative`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}DistRelative`,
            //osc
            decimals: 2,
            bypass: true,
            //scripting
            onValue:
              `var r = get('varInput${channelNum}EncR');\n\n` +

              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'di', value * r);\n\n` +

              `console.log(\`input${channelNum} distRel \${value}\`);\n\n` +

              `var azim = get('varInput${channelNum}Azim');\n` +
              `var elev = get('varInput${channelNum}Elev');\n` +
              `var dist = value * r;\n\n` +

              `var x,y,z;\n\n` +

              `x = -dist*Math.cos(elev*Math.PI/180)*Math.sin(azim*Math.PI/180);\n` +
              `y = dist*Math.cos(elev*Math.PI/180)*Math.cos(azim*Math.PI/180);\n` +
              `z = dist*Math.sin(elev*Math.PI/180);\n\n` +

              `set('varInput${channelNum}X',x, {script: false});\n` +
              `set('varInput${channelNum}Y', y, {script: false});\n` +
              `set('varInput${channelNum}Z', z/r, {script: false});\n` +
              `set('varInput${channelNum}XY', [x/r,y/r], {script: false});\n\n` +

              `set('varInput${channelNum}Dist', dist, {script: false});`
          });

          //ENC RADIUS
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}EncR`,
            //value
            default: 7,
            linkId: `${singularName}${channelNum}EncR`,
            //osc
            decimals: 2,
            bypass: true
          });

          //MUTE
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Mute`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}Mute`,
            //osc
            decimals: 0,
            bypass: true,
            //scripting
            onValue:
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'm', value);\n` +
              `console.log(\`input${channelNum} mute \${value}\`);`
          });

          //VOLUME
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}Volume`,
            //value
            default: 1,
            linkId: `${singularName}${channelNum}Volume`,
            //osc
            decimals: 6,
            bypass: true,
            //scripting
            onValue:
              `send(get('varSCLangAddress'), '/ch', 'p', {type: "i", value: ${channelNum}}, 'va', value);\n` +
              `console.log(\`input${channelNum} volume \${value}\`);`
          });

          //IN VOLUME METER
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}InVM`,
            //value
            default: 0,
            linkId: `>>${singularName}${channelNum}InVM`,
            //osc
            decimals: 6,
            bypass: true
          });

          //GAIN VOLUME METER
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}GainVM`,
            //value
            default: 0,
            linkId: `>>${singularName}${channelNum}GainVM`,
            //osc
            decimals: 6,
            bypass: true
          });

          //OUT VOLUME METER
          channelFolder.widgets.push({
            //widget
            type: 'variable',
            id: `var${singularName}${channelNum}OutVM`,
            //value
            default: [ 0, 0, 0, 0 ],
            linkId: `>>${singularName}${channelNum}OutVM`,
            //osc
            decimals: 6,
            bypass: true
          });

          break;
      
        default:
          break;
      }

      typeFolderWidgets.push(channelFolder);

    };

    receive( '/EDIT/MERGE', `fldr${pluralName}`, {
      widgets: typeFolderWidgets
    });

    /*let rowPanelWidgets = [];
    
    CreateChannelsPage( channelType, rowPanelWidgets, channelsOnPage );
    
    receive( '/EDIT/MERGE', 'pnl' + pluralName + 'Row', {
      tabs: null,
      widgets: rowPanelWidgets
    });*/
}

function CreateChannelsGroupTab( channelType, channelsGroup, groupsLevel, numFirst, numLast, channelsAmount, channelsOnPage, pagesInGroup, tabNameDef ) {

  let singularName = '';
  let pluralName = '';

  switch (channelType) {
    case 'input':
      singularName = 'Input';
      pluralName = 'Inputs';
      break;
  
    case 'mix':
      singularName = 'Mix';
      pluralName = 'Mixes';
      break;

    case 'point':
      singularName = 'Point';
      pluralName = 'Points';
      break;
    
    default:
      break;
  }

  let currentGroupTabs = [];
  let tabsAmount = Math.ceil( (numLast - numFirst + 1) / channelsOnPage / Math.pow(pagesInGroup, groupsLevel) );
  
  for ( let tabNum = 1; tabNum <= tabsAmount; tabNum++ ) {

    let tabNumFirst = (tabNum - 1)*Math.pow(pagesInGroup, groupsLevel)*channelsOnPage + numFirst;
    let tabNumLast = Math.min(tabNum*Math.pow(pagesInGroup, groupsLevel)*channelsOnPage + numFirst - 1, numLast);

    let tab = {
      type: 'tab',
      id: tabNameDef + tabNum,
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      tabsPosition: 'left',
      label: tabNumFirst + '-' + tabNumLast,

      widgets: null,
      tabs: null
    };

    currentGroupTabs.push(tab);

    if ( groupsLevel > 0 ) {

      CreateChannelsGroupTab( channelType, tab, groupsLevel - 1, tabNumFirst, tabNumLast, channelsAmount, channelsOnPage, pagesInGroup, tabNameDef + tabNum + '-');

    } else {

      let pageNum = (tabNumFirst - 1)/channelsOnPage + 1;

      let panel = {
        type: 'panel',
        id:'pnl' + pluralName + 'Page' + pageNum,
        //Geometry
        expand: true,
        //Panel Style
        scroll: false,
        innerPadding: false
      };

      CreateChannelsPage( channelType, panel, pageNum, channelsAmount, channelsOnPage );

      tab.widgets = [panel];
    }
  }
  channelsGroup.tabs = currentGroupTabs;
}

function CreateChannelsPage( channelType, pageWidgets, channelsOnPage ) {

  let singularName = '' , singularNameCaps = '';
  let pluralName = '';

  switch (channelType) {
      case 'input':
      singularName = 'Input';
      singularNameCaps = 'INPUT';
      pluralName = 'Inputs';
      break;
    
    case 'mix':
      singularName = 'Mix';
      singularNameCaps = 'MIX';
      pluralName = 'Mixes';
      break;

    case 'point':
      singularName = 'Point';
      singularNameCaps = 'POINT';
      pluralName = 'Points';
      break;
        
    default:
      break;
  }

  console.log(`CM Creating ${singularName} Rows Page`);

  for (let channelNum = 1; channelNum <= channelsOnPage; channelNum++) {
    //
    let channelPanelWidgets = [];

    //Label
    channelPanelWidgets.push({
      type: 'text',
      id: `lblUIRow${singularName}${channelNum}`,
      //Geometry
      left: 0,
      top: 0,
      width: 60,
      height: 40,
      //Style
      colorText: '#ffffff',
      //Value
      default: channelNum,
      value: channelNum
    });

    //'Open' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btnUIRow${singularName}${channelNum}Open`,
      //Geometry
      width: 60,
      height: 50,
      //Style
      colorText: '#ffffff',
      //css: "font-size:125%;",
      //Button Style
      label: 'OPEN',
      //Button
      mode: 'momentary',
      //Scripting
      onValue: "setVar('pnlInputsToolbar','visibility',0);\n"+
      "set('btnInputsShowRows',0);\n"+
      "setVar('pnlInputOptions','visibility',1);\n"+
      "setVar('pnlInputSelectedTop','visibility',1);\n"+
      `set('inpInputSelected',(get('varUIInputsPageSelected')-1)*${channelsOnPage}+${channelNum});`
    });

    //'Select' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btnUIRow${singularName}${channelNum}Select`,
      //Geometry
      width: 60,
      height: 50,
      //Style
      colorText: '#ffffff',
      //css: "font-size:125%;",
      //Button Style
      label: 'SEL',
      //Scripting
      onValue: ''
    });

    //'Mute' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btnUIRow${singularName}${channelNum}Mute`,
      //Geometry
      width: 60,
      height: 50,
      //Style
      colorText: '#ffffff',
      //css: "font-size:125%;",
      //Button Style
      label: 'MUTE',
      //Scripting
      onValue: ''
    });

    //Volume Panel
    channelPanelWidgets.push({
      //Widget
      type: 'panel',
      id: `pnlUIRow${singularName}${channelNum}Volume`,
      //Geometry
      height: 340,
      expand: true,
      //Style
      alphaStroke: 0,
      //Panel Style
      scroll: false,
      innerPadding: false,
      
      widgets: [{
        //Widget
        type: 'fader',
        id: `fdrUIRow${singularName}${channelNum}Volume`,
        //Geometry
        left: 0,
        top: "0%",
        width: 60,
        height: "100%",
        //Style
        colorText: '#ffffff',
        //Fader Style
        knobSize: 20,
        pips: true,
        dashed: true,
        //Fader
        doubleTap: true,
        range: "{\"max\": { \"+10\": 0.790569 },\n" +
        "\"91%\": { \"+5\": 0.44457 },\n" +
        "\"82%\": { \"0.0\": 0.25 },\n" +
        "\"73%\": { \"-5\": 0.140585 },\n" +
        "\"64%\": { \"-10\": 0.079057 },\n" +
        "\"55%\": { \"-15\": 0.044457 },\n" +
        "\"46%\": { \"-20\": 0.025 },\n" +
        "\"37%\": { \"-30\": 0.007906 },\n" +
        "\"28%\": { \"-40\": 0.0025 },\n" +
        "\"19%\": { \"-50\": 0.000791 },\n" +
        "\"10%\": { \"-60\": 0.00025 },\n" +
        "\"min\": { \"-inf\": 0.0 }}",
        sensitivity: "@{varUIFaderSensitivity}",
        //Value
        default: 0.25,
        //OSC
        decimals: 6
      },{
        //VM Panel
        type: 'panel',
        id: `pnlUIRow${singularName}${channelNum}VM`,
        //Geometry
        left: 25,
        top: "0%",
        width: 15,
        height: "100%",
        //Style
        alphaStroke: 0,
        padding: 0,
        //Panel Style
        layout: 'vertical',
        
        widgets: [{
          //VM Up Block
          type: 'panel',
          id: `pnlUIRow${singularName}${channelNum}VMUp`,
          //Geometry
          height: 12,
          //Style
          alphaStroke: 0,
        },{
          //Widget
          type: 'fader',
          id: `fdrUIRow${singularName}${channelNum}VM`,
          interaction: false,
          //Geometry
          expand: 'true',
          //Style
          colorText: '#ffffff',
          colorFill: '#97ff6a',
          //Fader Style
          design: 'compact',
          //Fader
          range: "{\"max\": { \"+10\": 0.949481 },\n" +
            "\"91%\": { \"+5\": 0.828787 },\n" +
            "\"82%\": { \"0.0\": 0.716 },\n" +
            "\"73%\": { \"-5\": 0.612454 },\n" +
            "\"64%\": { \"-10\": 0.518539 },\n" +
            "\"55%\": { \"-15\": 0.435375 },\n" +
            "\"46%\": { \"-20\": 0.363271 },\n" +
            "\"37%\": { \"-30\": 0.25009 },\n" +
            "\"28%\": { \"-40\": 0.170984 },\n" +
            "\"19%\": { \"-50\": 0.116622 },\n" +
            "\"10%\": { \"-60\": 0.079482 },\n" +
            "\"min\": { \"-inf\": 0 }}",
          //OSC
          decimals: 14
        },{
          //VM Down Block
          type: 'panel',
          id: `pnlUIRow${singularName}${channelNum}VMDown`,
          //Geometry
          height: 10,
          //Style
          alphaStroke: 0,
        }]
        
        
      }]
    });

    /*//'0 dB' Button
    channelPanelWidgets.push({
    //
    type: 'button',
    id: `btnUIRow${singularName}${channelNum}0dB`,
    //Geometry
    width: 60,
    height: 40,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'set\n0 dB',
    //Button
    mode: 'momentary',
    //Scripting
    onValue: `set('fdr${singularName}${channelNum}Volume', 0.716);`
    });

    //'-inf' Button
    channelPanelWidgets.push({
    //
    type: 'button',
    id: `btnUIRow${singularName}${channelNum}-Inf`,
    //Geometry
    width: 60,
    height: 40,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'set\n-inf',
    //Button
    mode: 'momentary',
    //Scripting
    onValue: `set('fdr${singularName}${channelNum}Volume', 0);`
    });*/

    pageWidgets.push({
      type: 'panel',
      id:'pnlUIRow' + singularName + channelNum,
      //Geometry
      width: 60,
      //Style
      alphaStroke: 0,
      //Panel Style
      layout: 'vertical',
      justify: 'space-around',
      scroll: false,
      innerPadding: false,
      
      widgets: channelPanelWidgets
    });
  }
}

module.exports = {

  init: function(){
    
  },

  oscInFilter:function(data){
    // Filter incoming osc messages
    
    var {address, args, host, port} = data
    
    if ( address === '/drawChans' ) {
      
      try {
        
        let channelType = args[0].value;
        let channelsAmount = args[1].value;
        let channelsOnPage = args[2].value;
        let pagesInGroup = args[3].value;
        
        console.log(`Task to Draw Channels. Type=${channelType} Amount=${channelsAmount}` +
          `OnPage=${channelsOnPage} PagesInGroup=${pagesInGroup}`);

        CreateChannels( channelType, channelsAmount, channelsOnPage, pagesInGroup );

        console.log('CM after func');
        
      } catch (e) {
        
      }
    }
    
    if ( address === '/sendtldr' ) {
      
      try {
        
        let count = args[0].value;
        
        let tfile = '';
        
        for ( let c = 1; c <= count; c++ ) {
          
          tfile += c + '-th string. Some content to weight by.\n';
          
        }
        
        receive('/EDIT/MERGE', 'txtIDELog', {
          
          value: tfile
          
        });
        
      } catch (e) {
        //
      }
    }
    
    return {address, args, host, port}
  },

  oscOutFilter:function(data){
    // Filter outgoing osc messages
    
    var {address, args, host, port, clientId} = data
    
    return {address, args, host, port}
  },

  unload: function(){
    
  },
}
