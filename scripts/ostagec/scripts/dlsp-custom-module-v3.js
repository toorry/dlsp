// Do whatever you want
// initialize variables
// declare functions
// load modules
// etc

//var fs = nativeRequire('fs')

var selfAddress = '127.0.0.1:8080';

function CreateMixes( mixesAmount, mixesOnPage, pagesInGroup ) {

  console.log('Creating Mixes..');

  var mixesPagesAmount = Math.ceil(mixesAmount / mixesOnPage);
  var mixesGroupsAmount = Math.ceil(mixesPagesAmount / pagesInGroup);
  var groupsLevels = Math.ceil( Math.log(mixesPagesAmount) / Math.log(pagesInGroup) );
  console.log('Groups Levels = ' + groupsLevels);

  var pnlMixesTabs = [];

  let topLevelGroupsCount = Math.ceil( mixesPagesAmount / Math.pow( pagesInGroup, groupsLevels - 1 ) );
  if ( topLevelGroupsCount == 1 ) { groupsLevels-- };
  console.log('Top level Groups count = ' + topLevelGroupsCount);

  if ( mixesPagesAmount == 1 ) {//One Page case
    //
    pnlMixesPage = {
      type: 'panel',
      id: 'pnlMixesPage1',
      //Geometry
      expand: true,
      //Panel Style
      layout: 'horizontal',
      scroll: false,
      innerPadding: false
    };
    CreateMixesPage( pnlMixesPage, 1, mixesAmount, mixesOnPage );
    console.log('Mix Page ' + 1 + ' created.');
    receive( '/EDIT/MERGE', 'pnlMixes', {
      tabs: null,
      widgets: [pnlMixesPage]
    })
  }
  else if ( mixesGroupsAmount == 1 ) {//One Group case

    for ( let i = 1; i <= mixesPagesAmount; i++ ) {

      let tabNumFirst = (i - 1)*mixesOnPage + 1;
      let tabNumLast =  Math.min(i*mixesOnPage, mixesAmount);

      let pnlMixesPage = {
        type: 'panel',
        id: 'pnlMixesPage' + i,
        //Geometry
        expand: true,
        //Panel Style
        layout: 'horizontal',
        scroll: false,
        innerPadding: false
      };

      pnlMixesTabs.push({
        type: 'tab',
        id: 'tabMixesPage' + i,
        //Panel Style
        layout: 'vertical',
        scroll: false,
        innerPadding: false,
        //Tab Style
        label: tabNumFirst + '-' + tabNumLast,

        widgets: [pnlMixesPage]
      });

      CreateMixesPage( pnlMixesPage, i, mixesAmount, mixesOnPage );
    }

    receive('/EDIT/MERGE', 'pnlMixes', {
      tabsPosition: 'left',
      widgets: null,
      tabs: pnlMixesTabs
    });

  } else {//Several Groups case
    console.log('Several groups case..');
    mixGroup = {
      tabs: null
    };
    console.log('Before recursive..');
    CreateMixesGroupTab( mixGroup, groupsLevels - 1, 1, mixesAmount, mixesAmount, mixesOnPage, pagesInGroup, 'tabMixesGroup' );
    receive('/EDIT/MERGE', 'pnlMixes', mixGroup);
  }
}

function CreateMixesGroupTab( mixGroup, groupsLevel, numFirst, numLast, mixesAmount, mixesOnPage, pagesInGroup, tabNameDef ) {
  //
  console.log('Creating groups at ' + groupsLevel + '-th level.');

  let currentGroupTabs = [];
  let tabsAmount = Math.ceil( (numLast - numFirst + 1) / mixesOnPage / Math.pow(pagesInGroup, groupsLevel) );
  console.log('tabsAmount = ' + tabsAmount);
  for ( let tabNum = 1; tabNum <= tabsAmount; tabNum++ ) {
    //
    //console.log(tabNum + '-th tab');
    let tabNumFirst = (tabNum - 1)*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst;
    let tabNumLast = Math.min(tabNum*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst - 1, numLast);
    //console.log(tabNum + '-th tabtab');
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
    //console.log(tabNum + '-th tabtabtab');

    currentGroupTabs.push(tab);
    //console.log(tabNum + ' tab');
    if ( groupsLevel > 0 ) {
      console.log('recursive tab ' + tabNumFirst + '-' + tabNumLast);
      CreateMixesGroupTab( tab, groupsLevel - 1, tabNumFirst, tabNumLast, mixesAmount, mixesOnPage, pagesInGroup, tabNameDef + tabNum + '-');
    } else {
      let pageNum = (tabNumFirst - 1)/mixesOnPage + 1;
      console.log('creating page ' + pageNum);
      let panel = {
        type: 'panel',
        id:'pnlMixesPage' + pageNum,
        //Geometry
        expand: true,
        //Panel Style
        scroll: false,
        innerPadding: false
      };
      //console.log('now pages 2');
      CreateMixesPage( panel, pageNum, mixesAmount, mixesOnPage );
      //console.log('now pages 3');
      tab.widgets = [panel];
    }
  }
  mixGroup.tabs = currentGroupTabs;
}

function CreateMixesPage( MixesPage, PageNum, MixesAmount, MixesOnPage ) {

  console.log('Creating Mixes Page ' + PageNum);
  let mixMin = (PageNum - 1)*MixesOnPage + 1;
  let mixMax = Math.min(PageNum*MixesOnPage, MixesAmount);

  //Create Tabs in Mixes Page
  let mixesPageTabs = [];
  MixesPage.tabs = mixesPageTabs;

  let allViewWidgets = [];

  mixesPageTabs.push({
    type: 'tab',
    id: 'tabMixesPage' + PageNum + 'All',
    //Panel Style
    layout: 'vertical',
    scroll: false,
    innerPadding: false,
    //Tab Style
    label: 'ALL',

    widgets: [{
      type: 'panel',
      id: 'pnlMixesPage' + PageNum + 'All',
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

  //Create Individual Mix Tabs
  for (let mixNum = mixMin; mixNum <= mixMax; mixNum++) {
    //
    let mixOptionsTabs = [];

    mixesPageTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum,
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: mixNum,

      widgets: [{
          type: 'panel',
          id:'pnlMix' + mixNum,
          //Geometry
          expand: true,
          //Panel Style
          layout: 'horizontal',
          scroll: false,
          innerPadding: false,

          tabs: mixOptionsTabs
        }]
    });

    //Create Mix Options Tabs
    let mixPage = [];

    //Mix Main Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'Main',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'MAIN'
    });

    //Mix EQ Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'EQ',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'EQ'
    });

    //Mix Gate Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'Gate',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'GATE'
    });

    //Mix Compressor Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'Comp',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'COMPRESSOR'
    });

    //Mix Limiter Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'Limit',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'LIMITER'
    });

    //Mix Sends Tab
    mixOptionsTabs.push({
      type: 'tab',
      id: 'tabMix' + mixNum + 'Sends',
      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'SENDS'
    });
  }

  //Create 'ALL' Mixes Page View
  let allPanelWidgets = [];

  //'Select All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btnMixAllSelect',
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

  //Volume All Panel
  allPanelWidgets.push({
    //Widget
    type: 'panel',
    id: 'pnlMixAllVolume',
    //Geometry
    height: 340,
    //Panel Style
    scroll: false,
    innerPadding: false,

    widgets: [{
      //Widget
      type: 'text',
      id: 'lblMixAllVolume',
      //Geometry
      left: 0,
      top: 0,
      width: 60,
      height: 40,
      //Style
      colorText: '#ffffff',
      //Value
      default: 'ALL'
    },{
      //Widget
      type: 'fader',
      id: 'fdrMixAllVolume',
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
      id: 'fdrMixAllVU',
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

  //'Mute All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btnMixAllMute',
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

  //'0 dB All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btnMixAll0dB',
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
    onValue: "for(let i = " + mixMin + "; i <= " + mixMax + "; i++){set('fdrMix' + i + 'Volume', 0.716)};"
  });

  //'-inf All' Button
  allPanelWidgets.push({
    //
    type: 'button',
    id: 'btnMixAll-Inf',
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
    onValue: "for(let i = " + mixMin + "; i <= " + mixMax + "; i++){set('fdrMix' + i + 'Volume', 0)};"
  });

  allViewWidgets.push({
    type: 'panel',
    id:'pnlAllMixAll',
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
  console.log('all view widgets');
  for (let mixNum = mixMin; mixNum <= mixMax; mixNum++) {
    //
    let mixPanelWidgets = [];

    //'Select' Button
    mixPanelWidgets.push({
      //
      type: 'button',
      id: 'btnMix' + mixNum + 'Select',
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

    //Volume Panel
    mixPanelWidgets.push({
      //Widget
      type: 'panel',
      id: 'pnlMix' + mixNum + 'Volume',
      //Geometry
      height: 340,
      //Panel Style
      scroll: false,
      innerPadding: false,

      widgets: [{
        //Widget
        type: 'text',
        id: 'lblMix' + mixNum + 'Volume',
        //Geometry
        left: 0,
        top: 0,
        width: 60,
        height: 40,
        //Style
        colorText: '#ffffff',
        //Value
        default: 'MIX\n' + mixNum
      },{
        //Widget
        type: 'fader',
        id: 'fdrMix' + mixNum + 'Volume',
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
        id: 'fdrMix' + mixNum + 'VU',
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

    //'Mute' Button
    mixPanelWidgets.push({
      //
      type: 'button',
      id: 'btnMix' + mixNum + 'Mute',
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
    mixPanelWidgets.push({
      //
      type: 'button',
      id: 'btnMix' + mixNum + '0dB',
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
      onValue: "set('fdrMix" + mixNum + "Volume', 0.716);"
    });

    //'-inf' Button
    mixPanelWidgets.push({
      //
      type: 'button',
      id: 'btnMix' + mixNum + '-Inf',
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
      onValue: "set('fdrMix" + mixNum + "Volume', 0);"
    });

    allViewWidgets.push({
      type: 'panel',
      id:'pnlAllMix' + mixNum,
      //Geometry
      width: 60,
      //Style
      alphaStroke: 0,
      //Panel Style
      layout: 'vertical',
      justify: 'space-around',
      scroll: false,
      innerPadding: false,

      widgets: mixPanelWidgets
    });
  }
}

module.exports = {

    init: function(){

    },

    oscInFilter:function(data){
        // Filter incoming osc messages

        var {address, args, host, port} = data

        if ( address === '/drawMix' ) {

          console.log('task to draw Mixes received');
          console.log(args);

          try {

            let mixesAmount = args[0].value;
            let mixesOnPage = args[1].value;
            let pagesInGroup = args[2].value;

            console.log('Mixes Amount = ' + mixesAmount);
            console.log('Mixes on Page = ' + mixesOnPage);
            console.log('Pages in Group = ' + pagesInGroup);

            CreateMixes( mixesAmount, mixesOnPage, pagesInGroup );

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
