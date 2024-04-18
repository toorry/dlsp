// Do whatever you want
// initialize variables
// declare functions
// load modules
// etc

//var fs = nativeRequire('fs')

var selfAddress = '127.0.0.1:8080';

async function drawMixes( mixesAmount, mixesOnPage, pagesInGroup ) {

  console.log('drawMixes function start');

  var mixesPagesAmount = Math.ceil(mixesAmount / mixesOnPage);
  var mixesGroupsAmount = Math.ceil(mixesPagesAmount / pagesInGroup);
  var primaryGroupsCount = mixesGroupsAmount;
  var groupsLevels = 1;

  var msgDelay = 500;

  var pnlMixes = new Object();

  if (mixesPagesAmount == 1) {//One page case
    //
    await new Promise(done => setTimeout(() => done(), msgDelay));
    pnlMixes.tabs = null;
    pnlMixes.widgets = [];
    pnlMixes.widgets.push({
      type: 'panel',
      id: 'pnlMixesPage1',
      //Geometry
      expand: true,
      //Panel Style
      layout: 'horizontal',
      scroll: false,
      innerPadding: false
    });

  } else {//Several pages case
    //
    var pnlMixesTabs = [];

    if(mixesGroupsAmount == 1) {//One group case
      //
      for (let i = 1; i <= mixesPagesAmount; i++) {
        //
        pnlMixesTabs.push({
          type: 'tab',
          id: 'tabMixesPage' + i
        });
      }

      //Create Tabs
      await new Promise(done => setTimeout(() => done(), msgDelay));
      pnlMixes.tabsPosition = 'left';
      pnlMixes.widgets = null;
      pnlMixes.tabs = pnlMixesTabs;

      //Configure Tabs
      for (let i = 1; i <= mixesPagesAmount; i++) {
        //
        let tabNumFirst = (i - 1)*mixesOnPage + 1;
        let tabNumLast =  Math.min(i*mixesOnPage, mixesAmount);
        await new Promise(done => setTimeout(() => done(), msgDelay));
        receive('/EDIT/MERGE', 'tabMixesPage' + i, {

          //Panel Style
          layout: 'vertical',
          scroll: false,
          innerPadding: false,
          //Tab Style
          label: tabNumFirst + '-' + tabNumLast,

          widgets: [{
            type: 'panel',
            id:'pnlMixesPage' + i,
            //Geometry
            expand: true,
            //Panel Style
            layout: 'horizontal',
            scroll: false,
            innerPadding: false
          }]
        });
      }

    } else {//Several Groups case
      //
      while (primaryGroupsCount > pagesInGroup) {
        //
        primaryGroupsCount /= pagesInGroup;
        groupsLevels++;
      }
      primaryGroupsCount = Math.ceil(primaryGroupsCount);

      createGroupTabs(groupsLevels, 1, mixesAmount, 'pnlMixes', 'tabMixesGroup');
    }
  }

  async function createGroupTabs(groupsLevel, numFirst, numLast, parentTabID, tabNameDef) {

    let currentGroupTabs = [];
    let tabsAmount = Math.ceil((numLast - numFirst + 1)/mixesOnPage/Math.pow(pagesInGroup, groupsLevel));

    for ( let tabNum = 1; tabNum <= tabsAmount; tabNum++ ) {
      //
      currentGroupTabs.push({
        type: 'tab',
        id: tabNameDef + tabNum
      });
    }

    //Create Tabs
    await new Promise(done => setTimeout(() => done(), msgDelay));
    receive('/EDIT/MERGE', parentTabID, {
      tabsPosition: 'left',
      widgets: null,
      tabs: currentGroupTabs
    });

    currentGroupTabs = null;

    //Configure Tabs
    for (let tabNum = 1; tabNum <= tabsAmount; tabNum++) {
      //
      let tabNumFirst = (tabNum - 1)*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst;
      let tabNumLast = Math.min(tabNum*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst - 1, numLast);
      //console.log('first=' + tabNumFirst + ' last=' + tabNumLast);

      await new Promise(done => setTimeout(() => done(), msgDelay));
      receive('/EDIT/MERGE', tabNameDef + tabNum, {
        //Panel Style
        layout: 'vertical',
        scroll: false,
        innerPadding: false,
        //Tab Style
        tabsPosition: 'left',
        label: tabNumFirst + '-' + tabNumLast,

        widgets: null,
        tabs: null
      });

      tabNumFirst = null;
      tabNumLast = null;
    }

    //Recursively Create Tabs
    if (groupsLevel > 0) {

      for (let tabNum = 1; tabNum <= tabsAmount; tabNum++) {
        //
        let tabNumFirst = (tabNum - 1)*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst;
        let tabNumLast = Math.min(tabNum*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst - 1, numLast);

        createGroupTabs(groupsLevel - 1, tabNumFirst, tabNumLast, tabNameDef + tabNum, tabNameDef + tabNum + '-');
        //setTimeout(function(){createGroupTabs(groupsLevel - 1, tabNumFirst, tabNumLast, tabNameDef + tabNum, tabNameDef + tabNum + '-')}, tabNum*500);
        tabNumFirst = null;
        tabNumLast = null;
      }
    } else {

      //Create Pages
      for (let tabNum = 1; tabNum <= tabsAmount; tabNum++) {
        //
        let tabNumFirst = (tabNum - 1)*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst;
        let tabNumLast = Math.min(tabNum*Math.pow(pagesInGroup, groupsLevel)*mixesOnPage + numFirst -1, numLast);
        let pageNum = (tabNumFirst - 1)/mixesOnPage + 1;

        await new Promise(done => setTimeout(() => done(), msgDelay));
        receive('/EDIT/MERGE', tabNameDef + tabNum, {

          //Panel Style
          layout: 'vertical',
          scroll: false,
          innerPadding: false,
          //Tab Style
          //label: tabNumFirst + '-' + tabNumLast,

          widgets: [{
            type: 'panel',
            id:'pnlMixesPage' + pageNum,
            //Geometry
            expand: true,
            //Panel Style
            scroll: false,
            innerPadding: false
          }]
        });

        tabNumFirst = null;
        tabNumLast = null;
        pageNum = null;
      }
    }
  }

  //Create Mixes
  for (let pageNum = 1; pageNum <= mixesPagesAmount; pageNum++) {

    //Create Tabs in Mixes Page
    let pageTabs = [];

    pageTabs.push({
      type: 'tab',
      id: 'tabMixesPage' + pageNum + 'All'
    });

    for (let mixNum = (pageNum - 1)*mixesOnPage + 1; mixNum <= Math.min(pageNum*mixesOnPage, mixesAmount); mixNum++) {
      //
      pageTabs.push({
        type: 'tab',
        id: 'tabMix' + mixNum
      });
    }

    await new Promise(done => setTimeout(() => done(), msgDelay));
    receive('/EDIT/MERGE', 'pnlMixesPage' + pageNum, {
      //
      tabs: pageTabs
    });
    pageTabs = null;

    await new Promise(done => setTimeout(() => done(), msgDelay));
    receive('/EDIT/MERGE', 'tabMixesPage' + pageNum + 'All', {

      //Panel Style
      layout: 'vertical',
      scroll: false,
      innerPadding: false,
      //Tab Style
      label: 'ALL',

      widgets: [{
        type: 'panel',
        id: 'pnlMixesPage' + pageNum + 'All',
        //Geometry
        expand: true,
        //Style
        //padding: 8,
        //Panel Style
        layout: 'horizontal',
        //justify: 'space-around',
        scroll: false,
        //innerPadding: false
        //Panel
        traversing: 'smart'
      }]
    });

    //Create 'ALL' Mixes Page View
    let allViewWidgets = [];

    for (let mixNum = (pageNum - 1)*mixesOnPage + 1; mixNum <= Math.min(pageNum*mixesOnPage, mixesAmount); mixNum++) {
      //
      allViewWidgets.push({
        type: 'panel',
        id:'pnlAllMix' + mixNum
      });
    }

    await new Promise(done => setTimeout(() => done(), msgDelay));
    receive('/EDIT/MERGE', 'pnlMixesPage' + pageNum + 'All', {

      widgets: allViewWidgets
    });
    allViewWidgets = null;

    //Individual Mix Panels on 'ALL' View
    for (let mixNum = (pageNum - 1)*mixesOnPage + 1; mixNum <= Math.min(pageNum*mixesOnPage, mixesAmount); mixNum++) {
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

      await new Promise(done => setTimeout(() => done(), msgDelay));
      receive('/EDIT/MERGE', 'pnlAllMix' + mixNum, {

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

    //Configure Individual Mix Tabs
    for (let mixNum = (pageNum - 1)*mixesOnPage + 1; mixNum <= Math.min(pageNum*mixesOnPage, mixesAmount); mixNum++) {
      //
      await new Promise(done => setTimeout(() => done(), msgDelay));
      receive('/EDIT/MERGE', 'tabMix' + mixNum, {

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
            innerPadding: false
          }]
      });

      //Create Mix Options Tabs
      let mixPage = [];

      //Mix Main Tab
      mixPage.push({
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
      mixPage.push({
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
      mixPage.push({
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
      mixPage.push({
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
      mixPage.push({
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
      mixPage.push({
        type: 'tab',
        id: 'tabMix' + mixNum + 'Sends',
        //Panel Style
        layout: 'vertical',
        scroll: false,
        innerPadding: false,
        //Tab Style
        label: 'SENDS'
      });

      //console.log('before');
      await new Promise(done => setTimeout(() => done(), msgDelay));
      //console.log('after');
      receive('/EDIT/MERGE', 'pnlMix' + mixNum, {
        //
        tabs: mixPage
      });
      mixPage = null;
      //
    }
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

            console.log(mixesAmount);
            console.log(mixesOnPage);
            console.log(pagesInGroup);
            console.log('osc args correct');

            drawMixes( mixesAmount, mixesOnPage, pagesInGroup );

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
