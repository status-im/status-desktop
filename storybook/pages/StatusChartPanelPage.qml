import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups

import Storybook

import utils

SplitView {
    id: root

    orientation: Qt.Vertical

    QtObject {
        id: d
        //dummy data
        property real stepSize: 1000
        property real minStep: 12000
        property real maxStep: 22000

        property var graphTabsModel: [{text: "Price", enabled: true}, {text: "Balance", enabled: true}]
        property var timeRangeTabsModel: [{text: "1H", enabled: true},
            {text: "1D", enabled: true},{text: "7D", enabled: true},
            {text: "1M", enabled: true}, {text: "6M", enabled: true},
            {text: "1Y", enabled: true}, {text: "ALL", enabled: true}]

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
            return result;
        }

        readonly property var lineConfig: {
            return {
                type: 'line',
                labels: d.timeRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange],
                datasets: [{
                    label: 'Price',
                    xAxisId: 'x-axis-1',
                    yAxisId: 'y-axis-1',
                    backgroundColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 0.2)' : 'rgba(67, 96, 223, 0.2)',
                    borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                    borderWidth: 3,
                    pointRadius: 0,
                    data: d.generateData()
                }],
                options: {
                    maintainAspectRatio: false,
                    responsive: true,
                    legend: {
                        display: false
                    },
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
                                //type: 'linear',
                                gridLines: {
                                    drawOnChartArea: false,
                                    drawBorder: false,
                                    drawTicks: false,
                                },
                                ticks: {
                                    fontSize: Theme.asideTextFontSize,
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
                                fontSize: Theme.asideTextFontSize,
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

        readonly property var barConfig: {
            return {
                type:"bar",
                options: {
                    onHover: function(event, activeElements) {
                        if (activeElements.length === 0) {
                            toolTip.close()
                            return
                        }

                        toolTip.text = "StatusMenu triggered by " + activeElements[0]._model.label
                        toolTip.popup()
                        toolTip.x += 10
                        toolTip.y -= toolTip.height + 10
                    },
                    tooltips: {
                        enabled:false
                    },
                    scales:{ 
                        xAxes:[{
                            id: "x-axis-1",
                            position: "bottom",
                            stacked: false,
                            gridLines: {
                                drawOnChartArea: false,
                                drawBorder: false,
                                drawTicks: false
                                },
                            ticks: {
                                fontSize: Theme.asideTextFontSize,
                                fontColor: "#939ba1",
                                padding:16
                            }
                        }],
                        yAxes: [{
                            position: "left",
                            id: "y-axis-1",
                            stacked: false,
                            gridLines: {
                                borderDash: [5,3],
                                lineWidth: 1,
                                drawBorder: false,
                                drawTicks: false,
                                color: "#33939ba1"
                            },
                            ticks: {
                                fontSize: Theme.asideTextFontSize,
                                fontColor: "#939ba1",
                                padding: 8,
                                maxTicksLimit: 10,
                                beginAtZero: true,
                                stepSize: 1
                            }
                        }]
                    }
                },
                labels:["16:40","16:50","17:00","17:10","17:20","17:30"],
                datasets: [{
                    xAxisId: "x-axis-1",
                    yAxisId: "y-axis-1",
                    backgroundColor: "#334360df",
                    pointRadius: 0,
                    hoverBackgroundColor: "#334360df",
                    hoverBorderColor: "#4360df",
                    hoverBorderWidth: 2,
                    data: [8,3,5,4,3,10]
                }]
            }
        }

        readonly property var crosshairConfig: {
            //binding to regenerate data and reset zoom
            chartType.currentText
            const generateDataset = (shift, label, color) => {
                var data = [];
                var x = 0;

                while (x < 30) {
                    data.push({ x: x, y: Math.sin(shift + x / 3) });
                    x += Math.random();
                }

                var dataset = {
                    backgroundColor: color,
                    borderColor: color,
                    showLine: true,
                    fill: false,
                    pointRadius: 2,
                    label: label,
                    data: data,
                    lineTension: 0,
                    interpolate: true
                };
                return dataset;
            }

            return {
                type: "scatter",
                options: {
                    plugins: {
                        crosshair: {
                            enabled: true,
                            sync: {
                                enabled: false
                            }
                        }
                    },
                    tooltips: {
                        mode: "interpolate",
                        intersect: true,
                    },
                    scales: {
                        xAxes: [{
                                id: 'x-axis-1',
                            }],
                        yAxes: [{
                            position: 'left',
                            id: 'y-axis-1',
                        }]
                    }
                },
                data: {
                    datasets: [
                    generateDataset(0, "A", "red"),
                    generateDataset(1, "B", "green"),
                    generateDataset(2, "C", "blue")
                    ]
                }
            };  
        }

        readonly property var minimisedConfig: {
            let config = Object.assign({}, d.lineConfig)
            config.datasets = [{
                    label: 'Price',
                    xAxisId: 'x-axis-1',
                    yAxisId: 'y-axis-1',
                    backgroundColor: "transparent",
                    borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                    borderWidth: 3,
                    pointRadius: 0,
                    data: d.generateData()
                }]
            config.options = Object.assign({}, d.lineConfig.options)

            config.options.scales = {
                xAxes: [{
                    id: 'x-axis-1',
                    display: false
                }],
                yAxes: [{
                    id: 'y-axis-1',
                    display: false
                }]
            }
            return config;
        }

        readonly property var dataLabelsConfig: {

            var DATA_COUNT = 8;
            var labels = [];

            for (var i = 0; i < DATA_COUNT; ++i) {
                labels.push('' + i);
            }

            return {
                type: 'line',
                labels: labels,
                datasets: [{
                    backgroundColor: "blue",
                    borderColor: "green",
                    data: [5, 10, 15, 10, 5, 0, 5, 10],
                    datalabels: {
                        align: 'start',
                        anchor: 'start'
                    }
                    }, {
                    backgroundColor:"red",
                    borderColor:"orance",
                    data: [58, 80, 60, 70, 50, 60, 70, 80],
                    }, {
                    backgroundColor: "yellow",
                    borderColor: "green",
                    data: [30, 40, 30, 40, 30, 40, 30, 40],
                    datalabels: {
                        align: 'end',
                        anchor: 'end'
                    }
                }],
                options: {
                    plugins: {
                    datalabels: {
                        backgroundColor: "red",
                        borderRadius: 4,
                        color: 'white',
                        font: {
                            weight: 'bold',
                            size: 12
                        },
                        formatter: Math.round,
                        padding: 6
                    }
                    },

                    // Core options
                    aspectRatio: 5 / 3,
                    layout: {
                    padding: {
                        top: 32,
                        right: 16,
                        bottom: 16,
                        left: 8
                    }
                    },
                    elements: {
                    line: {
                        fill: false
                    }
                    },
                    scales: {
                    yAxes: [{
                        stacked: true
                    }]
                    }
                }
            }
        }
    }

    StatusMenu {
        id: toolTip
        width: 243 //By design
        topPadding: Theme.padding
        bottomPadding: topPadding
        leftPadding: topPadding
        rightPadding: topPadding
        parent: Overlay.overlay
        property alias text: label.text
        Label {
            id: label
            text: "Tooltip"
            anchors.centerIn: parent
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

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
            chart.type: d.lineConfig.type
            chart.labels: d.lineConfig.labels
            chart.datasets: d.lineConfig.datasets
            chart.options: d.lineConfig.options
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        ComboBox {
            id: chartType
            model: d.lineConfig ? ["line", "bar", "with crosshair", "line minimised", "data labels"] : []
            currentIndex: 0
            onCurrentTextChanged: {
                if (chartType.currentText === "line") {
                    graphDetail.chart.type = d.lineConfig.type;
                    graphDetail.chart.labels = d.lineConfig.labels;
                    graphDetail.chart.datasets = d.lineConfig.datasets;
                    graphDetail.chart.options = d.lineConfig.options;
                    graphDetail.chart.plugins = []
                    graphDetail.chart.rebuild();
                } else if (chartType.currentText === "bar") {
                    graphDetail.chart.type = d.barConfig.type;
                    graphDetail.chart.labels = d.barConfig.labels;
                    graphDetail.chart.datasets = d.barConfig.datasets;
                    graphDetail.chart.options = d.barConfig.options;
                    graphDetail.chart.plugins = []
                    graphDetail.chart.rebuild();
                } else if (chartType.currentText === "with crosshair") {
                    graphDetail.chart.type = d.crosshairConfig.type;
                    graphDetail.chart.options = d.crosshairConfig.options;
                    graphDetail.chart.datasets = d.crosshairConfig.data.datasets;
                    graphDetail.chart.plugins = []
                    graphDetail.chart.rebuild();
                } else if (chartType.currentText === "line minimised") {
                    graphDetail.chart.type = d.minimisedConfig.type;
                    graphDetail.chart.labels = d.minimisedConfig.labels;
                    graphDetail.chart.datasets = d.minimisedConfig.datasets;
                    graphDetail.chart.options = d.minimisedConfig.options;
                    graphDetail.chart.plugins = []
                    graphDetail.chart.rebuild();
                } else if (chartType.currentText === "data labels") {
                    graphDetail.chart.type = d.dataLabelsConfig.type;
                    graphDetail.chart.datasets = d.dataLabelsConfig.datasets;
                    graphDetail.chart.labels = d.dataLabelsConfig.labels;
                    graphDetail.chart.options = d.dataLabelsConfig.options;
                    graphDetail.chart.plugins = [graphDetail.chart.availablePlugins.datalabels]
                    graphDetail.chart.rebuild();
                }
            }
        }
    }
}

// category: Panels
