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
      console.log('Creating Inputs..');
      singularName = 'Input';
      pluralName = 'Inputs';
      break;
  
    case 'mix':
      console.log('Creating Mixes..');
      singularName = 'Mix';
      pluralName = 'Mixes';
      break;

    case 'point':
      console.log('Creating Points..');
      singularName = 'Point';
      pluralName = 'Points';
      break;
    
    default:
      console.log('Default name');
      break;
  }

  var pagesAmount = Math.ceil(channelsAmount / channelsOnPage);
  var groupsAmount = Math.ceil(pagesAmount / pagesInGroup);
  var groupsLevels = Math.ceil( Math.log(pagesAmount) / Math.log(pagesInGroup) );
  var pnlChannelsTabs = [];

  let topLevelGroupsCount = Math.ceil( pagesAmount / Math.pow( pagesInGroup, groupsLevels - 1 ) );
  if ( topLevelGroupsCount == 1 ) { groupsLevels-- };
  if ( pagesAmount == 1 ) {//One Page case
    //
    console.log('One Page case');
    pnlChannelsPage = {
      type: 'panel',
      id: 'pnl' + pluralName + 'Page1',
      //Geometry
      expand: true,
      //Panel Style
      layout: 'horizontal',
      scroll: false,
      innerPadding: false
    };

    CreateChannelsPage( channelType, pnlChannelsPage, 1, channelsAmount, channelsOnPage );

    receive( '/EDIT/MERGE', 'pnl' + pluralName, {
      tabs: null,
      widgets: [pnlChannelsPage]
    });
  }
  else if ( groupsAmount == 1 ) {//One Group case

    for ( let i = 1; i <= pagesAmount; i++ ) {

      let tabNumFirst = (i - 1)*channelsOnPage + 1;
      let tabNumLast =  Math.min(i*channelsOnPage, channelsAmount);

      let pnlChannelsPage = {
        type: 'panel',
        id: 'pnl' + pluralName + 'Page' + i,
        //Geometry
        expand: true,
        //Panel Style
        layout: 'horizontal',
        scroll: false,
        innerPadding: false
      };

      pnlChannelsTabs.push({
        type: 'tab',
        id: 'tab' + pluralName + 'Page' + i,
        //Panel Style
        layout: 'vertical',
        scroll: false,
        innerPadding: false,
        //Tab Style
        label: tabNumFirst + '-' + tabNumLast,

        widgets: [pnlChannelsPage]
      });

      CreateChannelsPage( channelType, pnlChannelsPage, i, channelsAmount, channelsOnPage );
    }

    receive('/EDIT/MERGE', 'pnl' + pluralName, {
      tabsPosition: 'left',
      widgets: null,
      tabs: pnlChannelsTabs
    });

  } else {//Several Groups case

    channelsGroup = {
      tabs: null
    };

    CreateChannelsGroupTab( channelType, channelsGroup, groupsLevels - 1, 1, channelsAmount, channelsAmount, channelsOnPage, pagesInGroup, 'tab' + pluralName + 'Group' );

    receive('/EDIT/MERGE', 'pnl' + pluralName, channelsGroup);
  }
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

function CreateChannelsPage( channelType, channelsPage, pageNum, channelsAmount, channelsOnPage ) {

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

  let channelMin = (pageNum - 1)*channelsOnPage + 1;
  let channelMax = Math.min(pageNum*channelsOnPage, channelsAmount);

  console.log("Create Tabs in Channels Page");
  //Create Tabs in Channels Page
  let channelsPageTabs = [];
  channelsPage.tabs = channelsPageTabs;

  let allViewWidgets = [];

  channelsPageTabs.push({
    type: 'tab',
    id: 'tab' + pluralName + 'Page' + pageNum + 'All',
    //Panel Style
    layout: 'vertical',
    scroll: false,
    innerPadding: false,
    //Tab Style
    label: 'ALL',

    widgets: [{
      type: 'panel',
      id: 'pnl' + pluralName + 'Page' + pageNum + 'All',
      //Geometry
      expand: true,
      //Style
      //padding: 8,
      //Panel Style
      layout: 'horizontal',
      justify: 'space-around',
      scroll: false,
      //innerPadding: false
      //Panel
      traversing: 'smart',

      widgets: allViewWidgets
    }]
  });

  console.log('Create Individual Channel Tabs');
  //Create Individual Channel Tabs
  for (let channelNum = channelMin; channelNum <= channelMax; channelNum++) {

    let channelOptionsTabs = [];

    channelsPageTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum,
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: channelNum,

      widgets: [{
          type: 'panel',
          id:'pnl' + singularName + channelNum,
          //Geometry
          expand: true,
          //Panel Style
          layout: 'horizontal',
          scroll: false,
          innerPadding: false,

          tabs: channelOptionsTabs
        }]
    });

    console.log(`Create Channel ${channelNum} Options Tabs`);
    //Create Channel Options Tabs
    let channelPage = [];

    //Channel Main Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'Main',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'MAIN'
    });

    //Channel EQ Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'EQ',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'EQ'
    });

    //Channel Gate Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'Gate',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'GATE'
    });

    //Channel Compressor Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'Comp',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'COMPRESSOR'
    });

    //Channel Limiter Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'Limit',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'LIMITER'
    });

    //Channel Sends Tab
    channelOptionsTabs.push({
      type: 'tab',
      id: 'tab' + singularName + channelNum + 'Sends',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'SENDS'
    });
  }

  console.log('All Channels Page View');
  //Create 'ALL' Channels Page View
  let allPanelWidgets = [];

  //'Select All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btn' + pluralName + 'Page' + pageNum + 'AllSelect',
    //Geometry
    width: 60,
    height: 50,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'SEL\nALL',
    //Scripting
    onValue: ''
  });

  console.log('All button');
  //Volume All Panel
  allPanelWidgets.push({
    //Widget
    type: 'panel',
    id: 'pnl' + pluralName + 'Page' + pageNum + 'AllVolume',
    //Geometry
    height: 340,
    //Panel Style
    scroll: false,
    innerPadding: false,

    widgets: [{
      //Widget
      type: 'text',
      id: 'lbl' + pluralName + 'Page' + pageNum + 'AllVolume',
      //Geometry
      left: 0,
      top: 0,
      width: 60,
      height: 40,
      //Style
      colorText: '#ffffff',
      //Value
      default: 'ALL\nPage',
      value: 'ALL\nPage'
    },{
      //Widget
      type: 'fader',
      id: 'fdr' + pluralName + 'Page' + pageNum + 'AllVolume',
      //Geometry
      left: 0,
      top: 40,
      width: 60,
      height: 300,
      //Style
      colorText: '#ffffff',
      //Fader Style
      knobSize: 20,
      pips: true,
      dashed: true,
      //Fader
      doubleTap: true,
      range: "{\"max\": { \"+10\": 0.949481 },\"91%\": { \"+5\": 0.828787 },\"82%\": { \"0.0\": 0.716 },\"73%\": { \"-5\": 0.612454 },\"64%\": { \"-10\": 0.518539 },\"55%\": { \"-15\": 0.435375 },\"46%\": { \"-20\": 0.363271 },\"37%\": { \"-30\": 0.25009 },\"28%\": { \"-40\": 0.170984 },\"19%\": { \"-50\": 0.116622 },\"10%\": { \"-60\": 0.079482 },\"min\": { \"-inf\": 0 }}",
      sensitivity: "@{varInput1SendsfdrSensitivity}",
      //Value
      default: 0.25,
      //OSC
      decimals: 6
    },{
      //Widget
      type: 'fader',
      id: 'fdr' + pluralName + 'Page' + pageNum + 'AllVU',
      interaction: false,
      //Geometry
      left: 25,
      top: 52,
      width: 15,
      height: 278,
      //Style
      colorText: '#ffffff',
      colorFill: '#97ff6a',
      //Fader Style
      design: 'compact',
      //Fader
      range: "{\"max\": { \"+10\": 0.949481 },\"91%\": { \"+5\": 0.828787 },\"82%\": { \"0.0\": 0.716 },\"73%\": { \"-5\": 0.612454 },\"64%\": { \"-10\": 0.518539 },\"55%\": { \"-15\": 0.435375 },\"46%\": { \"-20\": 0.363271 },\"37%\": { \"-30\": 0.25009 },\"28%\": { \"-40\": 0.170984 },\"19%\": { \"-50\": 0.116622 },\"10%\": { \"-60\": 0.079482 },\"min\": { \"-inf\": 0 }}",
      //OSC
      decimals: 14
    }]
  });

  console.log('VolumeAll panel');
  //'Mute All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btn' + pluralName + 'Page' + pageNum + 'AllMute',
    //Geometry
    width: 60,
    height: 50,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'MUTE\nALL',
    //Scripting
    onValue: ''
  });

  //'0 dB All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btn' + pluralName + 'Page' + pageNum + 'All0dB',
    //Geometry
    width: 60,
    height: 40,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'set ALL\n0 dB',
    //Button
    mode: 'momentary',
    //Scripting
    onValue: `for(let i = ${channelMin}; i <= ${channelMax}; i++){set('fdr${singularName}' + i + 'Volume', 0.716)};`
  });

  //'-inf All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btn' + pluralName + 'Page' + pageNum + 'All-Inf',
    //Geometry
    width: 60,
    height: 40,
    //Style
    colorText: '#ffffff',
    //css: "font-size:125%;",
    //Button Style
    label: 'set ALL\n-inf',
    //Button
    mode: 'momentary',
    //Scripting
    onValue: `for(let i = ${channelMin}; i <= ${channelMax}; i++){set('fdr${singularName}' + i + 'Volume', 0)};`
  });

  console.log('All buttons');
  allViewWidgets.push({
    type: 'panel',
    id:`pnlAll${singularName}All`,
    //Geometry
    width: 60,
    //Style
    alphaStroke: 0,
    //Panel Style
    layout: 'vertical',
    justify: 'space-around',
    scroll: false,
    innerPadding: false,

    widgets: allPanelWidgets
  });
  console.log('adding widgets');

  for (let channelNum = channelMin; channelNum <= channelMax; channelNum++) {
    //
    let channelPanelWidgets = [];

    //'Select' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btn${singularName}${channelNum}Select`,
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
    console.log(`Individual Buttons ${channelNum}`);

    //Volume Panel
    channelPanelWidgets.push({
      //Widget
      type: 'panel',
      id: `pnl${singularName}${channelNum}Volume`,
      //Geometry
      height: 340,
      //Panel Style
      scroll: false,
      innerPadding: false,

      widgets: [{
        //Widget
        type: 'text',
        id: `lbl${singularName}${channelNum}Volume`,
        //Geometry
        left: 0,
        top: 0,
        width: 60,
        height: 40,
        //Style
        colorText: '#ffffff',
        //Value
        default: `${singularNameCaps}\n${channelNum}`,
        value: `${singularNameCaps}\n${channelNum}`
      },{
        //Widget
        type: 'fader',
        id: `fdr${singularName}${channelNum}Volume`,
        //Geometry
        left: 0,
        top: 40,
        width: 60,
        height: 300,
        //Style
        colorText: '#ffffff',
        //Fader Style
        knobSize: 20,
        pips: true,
        dashed: true,
        //Fader
        doubleTap: true,
        range: "{\"max\": { \"+10\": 0.949481 },\"91%\": { \"+5\": 0.828787 },\"82%\": { \"0.0\": 0.716 },\"73%\": { \"-5\": 0.612454 },\"64%\": { \"-10\": 0.518539 },\"55%\": { \"-15\": 0.435375 },\"46%\": { \"-20\": 0.363271 },\"37%\": { \"-30\": 0.25009 },\"28%\": { \"-40\": 0.170984 },\"19%\": { \"-50\": 0.116622 },\"10%\": { \"-60\": 0.079482 },\"min\": { \"-inf\": 0 }}",
        sensitivity: "@{varInput1SendsfdrSensitivity}",
        //Value
        default: 0.25,
        //OSC
        decimals: 6
      },{
        //Widget
        type: 'fader',
        id: `fdr${singularName}${channelNum}VU`,
        interaction: false,
        //Geometry
        left: 25,
        top: 52,
        width: 15,
        height: 278,
        //Style
        colorText: '#ffffff',
        colorFill: '#97ff6a',
        //Fader Style
        design: 'compact',
        //Fader
        range: "{\"max\": { \"+10\": 0.949481 },\"91%\": { \"+5\": 0.828787 },\"82%\": { \"0.0\": 0.716 },\"73%\": { \"-5\": 0.612454 },\"64%\": { \"-10\": 0.518539 },\"55%\": { \"-15\": 0.435375 },\"46%\": { \"-20\": 0.363271 },\"37%\": { \"-30\": 0.25009 },\"28%\": { \"-40\": 0.170984 },\"19%\": { \"-50\": 0.116622 },\"10%\": { \"-60\": 0.079482 },\"min\": { \"-inf\": 0 }}",
        //OSC
        decimals: 14
      }]
    });
    console.log('Mute');

    //'Mute' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btn${singularName}${channelNum}Mute`,
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

    //'0 dB' Button
    channelPanelWidgets.push({
      //
      type: 'button',
      id: `btn${singularName}${channelNum}0dB`,
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
      id: `btn${singularName}${channelNum}-Inf`,
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
    });
    console.log('Before adding panel widgets');

    allViewWidgets.push({
      type: 'panel',
      id:'pnlAll' + singularName + channelNum,
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
    console.log('Adding panel widgets');
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
