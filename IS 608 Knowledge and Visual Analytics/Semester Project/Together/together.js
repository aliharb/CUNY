
var conceptMap = [
        {
          econ: "ValueAdd",
          econTitle: "Value Add",
          score: "DemandScore"
        },

        {
          econ: "Exports",
          econTitle: "Exports",
          score: "ExportScore"
        },

        {
          econ: "BusinessInvestment",
          econTitle: "Business Investment",
          score: "InvestmentScore"
        },

        {
          econ: "Employment",
          econTitle: "Total Employment",
          score: "EmploymentScore"
        },

        {
          econ: "AWETot",
          econTitle: "Average Weekly Earnings: Total",
          score: "TotalLabourCostsScore"
        },

        {
          econ: "AWEReg",
          econTitle: "Average Weekly Earnings: Regular Pay",
          score: "PayScore"
        },

        {
          econ: "GrossOperatingSurplus",
          econTitle: "Gross Operating Surplus",
          score: "PreTaxProfitsScore"
        }
        ];
var globalCurrentOrFuture = "Current";
var globalEconConcept = "ValueAdd";
var globalSector = "Total";
var globalDate = "7/1/2008";
var sectorList = ["Total", "Business and financial services", 
  "Distribution, hotels, catering, arts, entertainment, recreation and other services",
  "Production", "Transport, storage and communications"];

var dateList = ["1/1/2008", "4/1/2008", "7/1/2008", "10/1/2008",
                "1/1/2009", "4/1/2009", "7/1/2009", "10/1/2009",
                "1/1/2010", "4/1/2010", "7/1/2010", "10/1/2010",
                "1/1/2011", "4/1/2011", "7/1/2011", "10/1/2011",
                "1/1/2012", "4/1/2012", "7/1/2012", "10/1/2012"];


function cvsmap(econ, conceptMap){
  var cvs;
  for(var i =0; i < conceptMap.length; i++){
    if(conceptMap[i].econ == econ){
      cvs = conceptMap[i].score;
    }
  }
  return cvs;
}
var globalCVSConcept = cvsmap(globalEconConcept, conceptMap);
var globalCVSConcept2 = "EmploymentScore";

var googleRawData = {};

dateList.forEach(function(d){
  googleRawData[d] = {
    surveyCount: [0,0,0,0,0,0,0,0,0,0,0],
    meanTally: [0,0,0,0,0,0,0,0,0,0,0]
  };
});

d3.select("#EconDropDown").append("select")
  .append("option")
  .text("")
  .attr("");

d3.select("#EconDropDown select")
  .selectAll("option")
  .data(conceptMap)
  .enter()
  .append("option")
  .text(function(d) { return d.econTitle; } )
  .attr("value", function(d) { return d.econ; } );

// d3.select("#EconDropDown select")
//   .on("change", function(){
//   })

var econChange = function(){
  globalEconConcept = d3.event.target.value;
  globalCVSConcept = cvsmap(globalEconConcept, conceptMap);

  if(d3.select("#EconDescription2 p").empty()){
    d3.select("#EconDescription2")
      .append("p")
      .text("The below data is sourced from the UK Office of National Statistics.");
  }

  drawEconGraph();
  if(!d3.select("#CVSChart svg g").empty()){
    drawMeanCVSGraph();
  }
  if(!d3.select("#CVSHist svg g").empty()){
    drawCVSHist();
  }

  drawGoogleChart();

  d3.select("#EconDescription3")
    .classed("hidden", false);

  if(d3.select("#CurrentOrFutureDropDown select").empty()){
    d3.select("#CurrentOrFutureDropDown").append("select");
  }

  d3.select("#CurrentOrFutureDropDown select")
    .selectAll("option")
    .data(["Current", "Future"])
    .enter()
    .append("option")
    .text(function(d) { return d; } )
    .attr("value", function(d) { return d; } );

  var currentOrFutureChange = function(){
    globalCurrentOrFuture = d3.event.target.value;
    drawMeanCVSGraph();
    if(!d3.select("#CVSHist svg g").empty()){
      drawCVSHist();
    }

    d3.select("#MeanCVSDescription")
      .classed("hidden", false);
  
    if(d3.select("#DateDropDown select").empty()){
      d3.select("#DateDropDown").append("select");
    }
    
    d3.select("#DateDropDown select")
      .selectAll("option")
      .data(dateList)
      .enter()
      .append("option")
      .text(function(d) { return d; } )
      .attr("value", function(d) { return d; } );

    var dateChange = function(){
      globalDate = d3.event.target.value;
      drawCVSHist();

      d3.select("#CVSHistDescription")
        .classed("hidden", false);

      if(d3.select("#SectorDropDown select").empty()){
        d3.select("#SectorDropDown").append("select");  
      }

      d3.select("#SectorDropDown select")
        .selectAll("option")
        .data(sectorList)
        .enter()
        .append("option")
        .text(function(d) { return d; } )
        .attr("value", function(d) { return d; } );

      var sectorChange = function(){
        globalSector = d3.event.target.value;
        drawMeanCVSGraph();
        drawCVSHist();
        drawGoogleChart();

        if(d3.select("#Concept2DropDown select").empty()){
          d3.select("#Concept2DropDown").append("select");
        }

        d3.select("#Concept2DropDown select")
          .selectAll("option")
          .data(conceptMap)
          .enter()
          .append("option")
          .text(function(d) { return d.econTitle; } )
          .attr("value", function(d) { return d.score; } );

        d3.select("#Concept2Description")
          .classed("hidden", false);

        var concept2Change = function(){
          globalCVSConcept2 = d3.event.target.value;
          drawGoogleChart();
          d3.select("#GoogleChart")
            .classed("hidden", false);
          d3.select("#Concept2Description2")
            .classed("hidden", false);
          // d3.select("#Conclusion")
          //   .classed("hidden", false);
        };

        d3.select("#Concept2DropDown select")
          .on("change", concept2Change);
      };

      d3.select("#SectorDropDown select")
        .on("change", sectorChange);
    };

    d3.select("#DateDropDown select")
      .on("change", function(){
        dateChange(); sectorChange();
      });
  };

  d3.select("#CurrentOrFutureDropDown select")
    .on("change", currentOrFutureChange);

};

d3.select("#EconDropDown select")
  .on("change", econChange);



// function drawEconGraph(globalEconConcept, globalCurrentOrFuture, globalSector, globalDate){

function drawEconGraph(){

  d3.csv("econdata.csv", function(error, data){ 

      function econData(concept) {

          var parseDate = d3.time.format("%m/%d/%Y").parse;

          var econSeries = [];

          data.forEach(function(d){
              econSeries.push({
                  x : parseDate(d.date), y : +d[concept]
              });
          });

          return [
              {
                  key: concept,
                  values: econSeries,
                  color: "#0000ff"
              }];

      }

      nv.addGraph(function() {
          var chart = nv.models.lineChart()
              .useInteractiveGuideline(true);

          chart.xAxis
              .axisLabel("Date")
              .tickFormat(function(d) { return d3.time.format("%b %Y")(new Date(d)); });

          chart.yAxis
              .axisLabel("Average Company Visit Score")
              .tickFormat(d3.format(".02f"))
              ;



          d3.select("#EconChart svg")
              .datum(econData(globalEconConcept))
              .transition().duration(500).call(chart);

          nv.utils.windowResize(
                  function() {
                      chart.update();
                  }
              );

          return chart;
      });

  });

}

  /////////////////////////////////////////////////////////////////////////

function drawMeanCVSGraph(){

  d3.csv("meancvs.csv", function(error, data){

      function meanCVSData(concept, sector, currentOrFuture) {

          var parseDate = d3.time.format("%m/%d/%Y").parse;

          var cvsSeries = [];

          data.forEach(function(d){
            if(d.Sector == sector && d.ScoreType == currentOrFuture){
                cvsSeries.push({
                    x : parseDate(d.date), y : +d[concept]
                });
            }
          });



          return [
              {
                  key: concept,
                  values: cvsSeries,
                  color: "#0000ff"
              }];

      }

      nv.addGraph(function() {
          var chart = nv.models.lineChart()
              .useInteractiveGuideline(true);

          chart.xAxis
              .axisLabel("Date")
              .tickFormat(function(d) { return d3.time.format("%b %Y")(new Date(d)); });

          chart.yAxis
              .axisLabel("Average Company Visit Score")
              .tickFormat(d3.format(".02f"))
              ;



          d3.select("#CVSChart svg")
              .datum(meanCVSData(globalCVSConcept, globalSector, globalCurrentOrFuture))
              .transition().duration(500).call(chart);

          nv.utils.windowResize(
                  function() {
                      chart.update();
                  }
              );

          return chart;
      });

  });

}

  /////////////////////////////////////////////////////////////////////////

function drawCVSHist(){

  d3.csv("agents.csv", function(error, data){

    function surveyData(sector, ActualDate, currentOrFuture, concept){
      // var parseDate = d3.time.format("%m/%d/%Y").parse;
      var surveyCounts = [0,0,0,0,0,0,0,0,0,0,0];

      // data.forEach(function(d){
      //   d.ActualDateDisplay = parseDate(d.ActualDateDisplay);
      // })

      data.forEach(function(d){
        if(sector == "Total"){
          if(d.ActualDateDisplay == ActualDate &&
              d.ScoreType == currentOrFuture){
            surveyCounts[+d[concept]+5] += 1;
          }
        } else {
          if(d.Sector == sector &&
              d.ActualDateDisplay == ActualDate &&
              d.ScoreType == currentOrFuture){
            surveyCounts[+d[concept]+5] += 1;
          }
        }
      });

      var returnData = [];

      surveyCounts.forEach(function(d, i){
        returnData.push({
          label: String(i-5),
          value: +surveyCounts[i]
        });
      });

      return [
        {
          key: "Company Visit Scores",
          values: returnData
        }];
    }

    nv.addGraph(function() {

        var chart = nv.models.discreteBarChart()
            .x(function(d) { return d.label; })
            .y(function(d) { return d.value; })
            .staggerLabels(true)
            //.staggerLabels(historicalBarChart[0].values.length > 8)
            .tooltips(true)
            .showValues(false)
            .duration(250)
            ;

        chart.yAxis
          .axisLabel("Number of Company Visits")
          .tickFormat(function(d){ return Math.round(d); });  

        d3.select("#CVSHist svg")
            .datum(surveyData(globalSector,globalDate, globalCurrentOrFuture, globalCVSConcept))
            .call(chart);
        nv.utils.windowResize(function() { chart.update(); } );
        return chart;
    });

  });

}

  /////////////////////////////////////////////////////////////////////////

google.load("visualization", "1", {packages:["motionchart"]});
google.setOnLoadCallback(drawGoogleChart);
function drawGoogleChart() {
  googleRawData = {};

  dateList.forEach(function(d){
  googleRawData[d] = {
      surveyCount: [0,0,0,0,0,0,0,0,0,0,0],
      meanTally: [0,0,0,0,0,0,0,0,0,0,0]
    };
  });
  
  d3.csv("agents.csv", function(error, data){
    function googleSurveyData(sector, currentOrFuture, concept1, concept2){

      function increment(item){
        var concept1Score = +item[concept1];
        var concept2Score = +item[concept2];
        var currentMean = googleRawData[item.ActualDateDisplay].meanTally[concept1Score+5];
        var currentCount = googleRawData[item.ActualDateDisplay].surveyCount[concept1Score+5];

        if(currentCount === 0){
          googleRawData[item.ActualDateDisplay].meanTally[+item[concept1]+5] = concept2Score;
          googleRawData[item.ActualDateDisplay].surveyCount[+item[concept1]+5] += 1;
        } else{
          googleRawData[item.ActualDateDisplay].meanTally[+item[concept1]+5] = 
            (currentMean * currentCount + concept2Score) / (currentCount + 1);
            googleRawData[item.ActualDateDisplay].surveyCount[+item[concept1]+5] += 1;
        }

        
      }
      
      data.forEach(function(d){
        if(sector == "Total"){
          if(d.ScoreType == currentOrFuture){
            increment(d);
          }
        } else{
          if(d.ScoreType == currentOrFuture && d.Sector == sector){
            increment(d);
          }
        }

      });

    }

    googleSurveyData(globalSector, globalCurrentOrFuture, globalCVSConcept, globalCVSConcept2);

    var dataForGoogle = [];

    var parseDate = d3.time.format("%m/%d/%Y").parse;

    dateList.forEach(function(d){
      for(var i=0; i<googleRawData[d].surveyCount.length; i++){
        dataForGoogle.push([
          String(i-5), parseDate(d), i-5,  googleRawData[d].meanTally[i], "Color", googleRawData[d].surveyCount[i]
        ]);
      }
    });

    var chartData = new google.visualization.DataTable();
    chartData.addColumn('string', globalCVSConcept);
    chartData.addColumn('date', 'Date');
    chartData.addColumn('number', globalCVSConcept);
    chartData.addColumn('number', globalCVSConcept2);
    chartData.addColumn('string', 'ColorPlaceHolder');
    chartData.addColumn('number', 'SurveyCount');
    chartData.addRows(dataForGoogle);
    var chart = new google.visualization.MotionChart(document.getElementById('GoogleChart'));
    chart.draw(chartData, {width: 1200, height:600});

  });  

}