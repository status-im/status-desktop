import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import Sandbox 0.1

Item {

    QtObject {
        id: d
        //dummy data
        property real stepSize: 1000
        property real minStep: 12000
        property real maxStep: 22000

        property var graphTabsModel: [{text: "Price", enabled: true}, {text: "Balance", enabled: false}]
        property var timeRangeTabsModel: [{text: "1H", enabled: true},
                {text: "1D", enabled: true},{text: "7D", enabled: true},
                {text: "1M", enabled: true}, {text: "6M", enabled: true},
                {text: "1Y", enabled: true}, {text: "ALL", enabled: true}]

        property var simTimer: Timer {
            running: true
            interval: 3000
            repeat: true
            onTriggered: {
                d.generateData();
            }
        }

        function minutes(minutes = 0) {
            var newMinute = new Date(new Date().getTime() - (minutes * 60 * 1000)).toString();
            if (newMinute.slice(10,12) === "00") {
                var dateToday = new Date(Date.now()).toString();
                return dateToday.slice(4,7) + " " + dateToday.slice(8,10);
            }
            return newMinute.slice(10,16);
        }

        function hour(hours = 0) {
            var newHour = new Date(new Date().getTime() - (hours * 60 * 60 * 1000)).toString();
            if (newHour.slice(10,12) === "00") {
                var dateToday = new Date(Date.now()).toString();
                return dateToday.slice(4,7) + " " + dateToday.slice(8,10);
            }
            return newHour.slice(10,16);
        }

        function day(before = 0) {
            var newDay = new Date(Date.now() - before * 24 * 60 * 60 * 1000).toString();
            return newDay.slice(4,7) + " " + newDay.slice(8,10);
        }

        function month(before = 0) {
            var newMonth = new Date(Date.now() - before * 24 * 60 * 60 * 1000).toString();
            return newMonth.slice(4,7) + " '" + newMonth.slice(newMonth.indexOf("G")-3, newMonth.indexOf("G")-1);
        }

        property var timeRange: [
            {'1H': [minutes(60), minutes(55), minutes(50), minutes(45), minutes(40), minutes(35), minutes(30), minutes(25), minutes(20), minutes(15), minutes(10), minutes(5), minutes()]},
            {'1D': [hour(24), hour(23), hour(22), hour(21), hour(20), hour(19), hour(18), hour(17), hour(16), hour(15), hour(14), hour(13),
                    hour(12), hour(11), hour(10), hour(9), hour(8), hour(7), hour(6), hour(5), hour(4), hour(3), hour(2), hour(1), hour()]},
            {'7D': [day(6), day(5), day(4), day(3), day(2), day(1), day()]},
            {'1M': [day(30), day(28), day(26), day(24), day(22), day(20), day(18), day(16), day(14), day(12), day(10), day(8), day(6), day(4), day()]},
            {'6M': [month(150), month(120), month(90), month(60), month(30), month()]},
            {'1Y': [month(330), month(300), month(270), month(240), month(210), month(180), month(150), month(120), month(90), month(60), month(30), month()]},
            {'ALL': ['2016', '2017', '2018', '2019', '2020', '2021', '2022']}
        ]

        function generateData() {
            var result = [];
            for (var i = 0; i < timeRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange].length; ++i) {
                result[i] = Math.random() * (maxStep - minStep) + minStep;
            }
            graphDetail.chart.chartData.datasets[0].data = result;
            graphDetail.chart.animateToNewData();
        }
    }

    StatusChartPanel {
        id: graphDetail
        height: 290
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        graphsModel: d.graphTabsModel
        timeRangeModel: d.timeRangeTabsModel
        onHeaderTabClicked: {
            //TODO
            //if time range tab
            d.generateData();
            //if graph bar
            //switch graph
        }
        chart.chartType: 'line'
        chart.chartData: {
            return {
                labels: d.timeRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange],
                datasets: [{
                    label: 'Price',
                    xAxisId: 'x-axis-1',
                    yAxisId: 'y-axis-1',
                    backgroundColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 0.2)' : 'rgba(67, 96, 223, 0.2)',
                    borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                    borderWidth: 3,
                    pointRadius: 0,
                    //data: d.generateData()
                }]
            }
        }

        chart.chartOptions: {
            return {
                maintainAspectRatio: false,
                responsive: true,
                legend: {
                    display: false
                },
                //TODO enable zoom
//                zoom: {
//                    enabled: true,
//                    drag: true,
//                    speed: 0.1,
//                    threshold: 2
//                },
//                pan:{enabled:true,mode:'x'},
                tooltips: {
                    intersect: false,
                    displayColors: false,
                    callbacks: {
                        footer: function(tooltipItem, data) { return 'Vol: $43,042,678,876'; },
                        label: function(tooltipItem, data) {
                          let label = data.datasets[tooltipItem.datasetIndex].label || '';
                            if (label) {
                                label += ': ';
                            }
                            label += tooltipItem.yLabel.toFixed(2);
                            return label.slice(0,label.indexOf(":")+1)+ " $"+label.slice(label.indexOf(":")+2, label.length);
                       }
                    }
                },
                scales: {
                    xAxes: [{
                       id: 'x-axis-1',
                       position: 'bottom',
                       gridLines: {
                           drawOnChartArea: false,
                           drawBorder: false,
                           drawTicks: false,
                       },
                       ticks: {
                           fontSize: 10,
                           fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                           padding: 16
                       }
                    }],
                    yAxes: [{
                       position: 'left',
                       id: 'y-axis-1',
                       gridLines: {
                          borderDash: [8, 4],
                          drawBorder: false,
                          drawTicks: false,
                          color: (Theme.palette.name === "dark") ? '#909090' : '#939BA1'
                       },
                       beforeDataLimits: (axis) => {
                          axis.paddingTop = 25;
                          axis.paddingBottom = 0;
                        },
                       ticks: {
                          fontSize: 10,
                          fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                          padding: 8,
                          min: d.minStep,
                          max: d.maxStep,
                          stepSize: d.stepSize,
                          callback: function(value, index, ticks) {
                                return '$' + value;
                          },
                       }
                    }]
                }
            }
        }
    }
}
