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
    
    let fldrUIChannelsPages = {
        widgets: []
    };

    /*for ( let pageNum = 1; pageNum <= pagesAmount; pageNum++ ) {

        let tabNumFirst = (pageNum - 1)*channelsOnPage + 1;
        let tabNumLast =  Math.min(pageNum*channelsOnPage, channelsAmount);

        fldrUIChannelsPages.widgets.push({

            type: 'variable',
            id: 'varUI' + pluralName + 'Page' + pageNum,
            value: {
                number: pageNum,
                first: tabNumFirst,
                last: tabNumLast,
                label: `${tabNumFirst}-${tabNumLast}`
            }
        });
    }*/

    receive( '/EDIT/MERGE', `fldrUI${pluralName}Pages`, fldrUIChannelsPages);

    let fldrUIGroupsWidgets = [];
    let pnlRowsGroupsWidgets = [];
    let currentLevelGroupsAmount = 0;
    console.log(`CM ${pluralName} groupsAmount=${groupsAmount} pagesInGroup=${pagesInGroup}`);

    for ( let groupsLevel = groupsLevels; groupsLevel > 0; groupsLevel-- ) {
        //
        let currentLevelGroupsButtons = [];

        currentLevelGroupsAmount = Math.ceil( pagesAmount / Math.pow( pagesInGroup, groupsLevel ) );
        console.log(`level ${groupsLevel}. ${currentLevelGroupsAmount} groups`);

        fldrUIGroupsWidgets.push({
            //
            type: 'variable',
            id: `varUI${pluralName}Lvl${groupsLevel}GroupsAmount`,
            value: currentLevelGroupsAmount
        });

        fldrUIGroupsWidgets.push({
            //
            type: 'variable',
            id: `varUI${pluralName}Lvl${groupsLevel}GroupSelected`,
            value: 1
        });

        currentLevelGroupsButtons = [];

        for ( let groupNum = 1; groupNum <= pagesInGroup; groupNum++ ) {
            //
            currentLevelGroupsButtons.push({
                //
                type: 'button',
                id: `btn${pluralName}Group${groupsLevel}-${groupNum}`,
                visible: "VAR{'visibility', 1}",
                label: "VAR{'btnLabel', ''}",
                wrap: 'soft'
            });
        }

        pnlRowsGroupsWidgets.push({
            //
            type: 'panel',
            id: `pnl${pluralName}RowsGroupsLvl${groupsLevel}`,
            //Geometry
            width: 65,
            padding: 0,
            //Panel Style
            layout: 'vertical',
            justify: 'start',
            contain: true,
            scroll: false,
            innerPadding: false,

            widgets: currentLevelGroupsButtons
        });
    }

    receive( '/EDIT/MERGE', `pnl${pluralName}RowsGroups`, {
        width: 65 * groupsLevels,
        widgets: pnlRowsGroupsWidgets
    });

    receive( '/EDIT/MERGE', `fldrUI${pluralName}Groups`, {
        //
        widgets: fldrUIGroupsWidgets
    });

    if ( pagesAmount > 1 ) {//Several Pages Case
    
        if ( groupsAmount == 1 ) {//One Group Case

            console.log('one group case');
            let pnlChannelsRowsPages = {
                widgets: []
            };

            for ( let pageNum = 1; pageNum <= pagesAmount; pageNum++ ) {
                
                pnlChannelsRowsPages.widgets.push({
                    
                    type: 'button',
                    id: `btn${pluralName}RowsPage${pageNum}`,
                    label: "VAR{'btnLabel', ''}",
                    onValue: `if(value==1){\n  set('varUIInputsPageSelected', ${pageNum});\n` +
                    `  setVar('pnlInputsRows', 'currentPage', ${pageNum});\n` +
                    "  set('scrUIInputsRowsUpdatePage', 1);\n}"
                });
                
            }

            receive( '/EDIT/MERGE', `pnl${pluralName}RowsPages`, pnlChannelsRowsPages);

            receive( `/varUI${pluralName}PagesAmount`, pagesAmount);
            receive( `/varUI${pluralName}PageSelected`, 1);

            receive('/scrUIInputsRowsUpdatePage', 1);

        } else {//Several Groups Case

            console.log('Several groups case');
            let pnlChannelsRowsPages = {
                widgets: []
            };

            for ( let pageNum = 1; pageNum <= pagesInGroup; pageNum++ ) {
                
                pnlChannelsRowsPages.widgets.push({
                    
                    type: 'button',
                    id: `btn${pluralName}RowsPage${pageNum}`,
                    label: "VAR{'btnLabel', ''}",
                    onValue: `if(value==1){\n  set('varUI${pluralName}PageSelected', ${pageNum});\n` +
                    `  setVar('pnl${pluralName}Rows', 'currentPage', ${pageNum});\n` +
                    `  set('scrUI${pluralName}RowsUpdatePage', 1);\n}`
                });
                
            }

            receive( '/EDIT/MERGE', `pnl${pluralName}RowsPages`, pnlChannelsRowsPages);

            receive( `/varUI${pluralName}GroupsAmount`, groupsAmount);
            receive( `/varUI${pluralName}PagesAmount`, pagesAmount);
            receive( `/varUI${pluralName}PageSelected`, 1);

            receive(`/scrUI${pluralName}RowsUpdatePage`, 1);
            receive(`/scrUI${pluralName}RowsUpdateGroupButtons`, 1);
        }
    } else {//One Page Case
        
        receive( `/varUI${pluralName}GroupsAmount`, 1);
        receive( `/varUI${pluralName}PagesAmount`, 1);
        receive( `/varUI${pluralName}PageSelected`, 1);

        receive( '/EDIT/MERGE', `pnl${pluralName}RowsGroups`, {
            widgets: []
        });

        receive( '/EDIT/MERGE', `pnl${pluralName}RowsPages`, {
            widgets: []
        });
    }

    //Create Variables for Input Channels
    let fldrInputsWidgets = [];

    for ( let channelNum = 1; channelNum <= channelsAmount; channelNum++ ) {
      
      fldrInputsWidgets.push({
        
        type: 'folder',
        id: `fldr${singularName}${channelNum}`,
        widgets: [
          //
          {
            type: 'variable',
            id: 'cha'
          }
        ]
      });
    }

    let rowPanelWidgets = [];
    
    CreateChannelsPage( channelType, rowPanelWidgets, channelsOnPage );
    
    receive( '/EDIT/MERGE', 'pnl' + pluralName + 'Row', {
      tabs: null,
      widgets: rowPanelWidgets
    });
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

    console.log('Create Channels Page func');
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
            `set('inpInputSelected',(getVar('pnlInputsRows','currentPage')-1)*${channelsOnPage}+${channelNum});`
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
            range: "{\"max\": { \"+10\": 0.790569 }," +
              "\"91%\": { \"+5\": 0.44457 }," +
              "\"82%\": { \"0.0\": 0.25 }," +
              "\"73%\": { \"-5\": 0.140585 }," +
              "\"64%\": { \"-10\": 0.079057 }," +
              "\"55%\": { \"-15\": 0.044457 }," +
              "\"46%\": { \"-20\": 0.025 }," +
              "\"37%\": { \"-30\": 0.007906 }," +
              "\"28%\": { \"-40\": 0.0025 }," +
              "\"19%\": { \"-50\": 0.000791 }," +
              "\"10%\": { \"-60\": 0.00025 }," +
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
              range: "{\"max\": { \"+10\": 0.949481 },\"91%\": { \"+5\": 0.828787 },\"82%\": { \"0.0\": 0.716 },\"73%\": { \"-5\": 0.612454 },\"64%\": { \"-10\": 0.518539 },\"55%\": { \"-15\": 0.435375 },\"46%\": { \"-20\": 0.363271 },\"37%\": { \"-30\": 0.25009 },\"28%\": { \"-40\": 0.170984 },\"19%\": { \"-50\": 0.116622 },\"10%\": { \"-60\": 0.079482 },\"min\": { \"-inf\": 0 }}",
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

            console.log(`Task to Draw Channels. Type=${channelType} Amount=${channelsAmount} OnPage=${channelsOnPage} PagesInGroup=${pagesInGroup}`);
            //console.log('Mixes on Page = ' + mixesOnPage);
            //console.log('Pages in Group = ' + pagesInGroup);
            CreateChannels( channelType, channelsAmount, channelsOnPage, pagesInGroup );
            console.log('after func');

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
