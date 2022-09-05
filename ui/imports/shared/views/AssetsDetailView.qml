import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0
import shared.controls 1.0

import "../stores"

Item {
    id: root

    property var token

    QtObject {
        id: d
        //dummy data
        property real stepSize: 1000
        property real minStep: 12000
        property real maxStep: 22000

        property var graphTabsModel: [{text: qsTr("Price"), enabled: true}, {text: qsTr("Balance"), enabled: false}]
        property var timeRangeTabsModel: [{text: qsTr("1H"), enabled: true},
                {text: qsTr("1D"), enabled: true},{text: qsTr("7D"), enabled: true},
                {text: qsTr("1M"), enabled: true}, {text: qsTr("6M"), enabled: true},
                {text: qsTr("1Y"), enabled: true}, {text: qsTr("ALL"), enabled: true}]

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
            for (var i = 0; i < timeRange[graphDetailLoader.item.timeRangeTabBarIndex][graphDetailLoader.item.selectedTimeRange].length; ++i) {
                result[i] = Math.random() * (maxStep - minStep) + minStep;
            }
            graphDetailLoader.item.chart.chartData.datasets[0].data = result;
            graphDetailLoader.item.chart.animateToNewData();
        }
    }

    signal goBack()
    StatusFlatButton {
        id: backButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -Style.current.xlPadding
        anchors.leftMargin: -Style.current.xlPadding
        icon.name: "arrow-left"
        icon.width: 20
        icon.height: 20
        text: qsTr("Assets")
        size: StatusBaseButton.Size.Large
        onClicked: root.goBack()
    }

    AssetsDetailsHeader {
        id: tokenDetailsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        asset.name: token && token.symbol ? Style.png("tokens/%1".arg(token.symbol)) : ""
        asset.isImage: true
        primaryText: token ? token.name : ""
        secondaryText: token ? qsTr("%1 %2").arg(Utils.toLocaleString(token.totalBalance, RootStore.locale, {"currency": true})).arg(token.symbol) : ""
        tertiaryText: token ? "%1 %2".arg(Utils.toLocaleString(token.totalCurrencyBalance.toFixed(2), RootStore.locale, {"currency": true})).arg(RootStore.currencyStore.currentCurrency.toUpperCase()) : ""
        balances: token && token.balances ? token.balances :  null
        getNetworkColor: function(chainId){
            return RootStore.getNetworkColor(chainId)
        }
        getNetworkIcon: function(chainId){
            return RootStore.getNetworkIcon(chainId)
        }
    }

    Loader {
        id: graphDetailLoader
        width: parent.width
        height: 290
        anchors.top: tokenDetailsHeader.bottom
        anchors.topMargin: 24
        active: root.visible
        sourceComponent: StatusChartPanel {
            id: graphDetail
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
                    //zoom: {
                    //  enabled: true,
                    //  drag: true,
                    //  speed: 0.1,
                    //  threshold: 2
                    //},
                    //pan:{enabled:true,mode:'x'},
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
                                    padding: 16,
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

    ColumnLayout {
        anchors.top: graphDetailLoader.bottom
        anchors.topMargin: 24
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        width: parent.width

        spacing: Style.current.padding

        RowLayout {
            Layout.fillWidth: true
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Market Cap")
                secondaryText: token && token.marketCap !== "" ? token.marketCap : "---"
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day Low")
                secondaryText: token && token.lowDay !== "" ? token.lowDay : "---"
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day High")
                secondaryText: token && token.highDay ? token.highDay : "---"
            }
            Item {
                Layout.fillWidth: true
            }
            InformationTile {
                readonly property string changePctHour: token ? token.changePctHour : ""
                maxWidth: parent.width
                primaryText: qsTr("Hour")
                secondaryText: changePctHour ? "%1%".arg(changePctHour) : "---"
                secondaryLabel.color: Math.sign(Number(changePctHour)) === 0 ? Theme.palette.directColor1 :
                                                                               Math.sign(Number(changePctHour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                         Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePctDay: token ? token.changePctDay : ""
                maxWidth: parent.width
                primaryText: qsTr("Day")
                secondaryText: changePctDay ? "%1%".arg(changePctDay) : "---"
                secondaryLabel.color: Math.sign(Number(changePctDay)) === 0 ? Theme.palette.directColor1 :
                                                                              Math.sign(Number(changePctDay)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                       Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePct24hour: token ? token.changePct24hour : ""
                maxWidth: parent.width
                primaryText: qsTr("24 Hours")
                secondaryText: changePct24hour ? "%1%".arg(changePct24hour) : "---"
                secondaryLabel.color: Math.sign(Number(changePct24hour)) === 0 ? Theme.palette.directColor1 :
                                                                                 Math.sign(Number(changePct24hour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                             Theme.palette.successColor1
            }
        }

        StatusTabBar {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Overview")
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusScrollView {
                id: scrollView
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                topPadding: 8
                bottomPadding: 8
                Flow {
                    id: detailsFlow

                    readonly property bool isOverflowing:  detailsFlow.width - tagsLayout.width - tokenDescriptionText.width < 24

                    spacing: 24

                    width: scrollView.availableWidth
                    StatusBaseText {
                        id: tokenDescriptionText
                        width: Math.max(536 , scrollView.availableWidth - tagsLayout.width - 24)

                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        text: token ? token.description : ""
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        textFormat: Qt.RichText
                    }
                    ColumnLayout {
                        id: tagsLayout
                        spacing: 10
                        InformationTag {
                            id: website
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight
                            iconAsset.icon: "browser"
                            tagPrimaryLabel.text: qsTr("Website")
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.assetWebsiteUrl !== ""
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.openLink(token.assetWebsiteUrl)
                            }
                        }
                        InformationTag {
                            id: smartContractAddress
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight

                            image.source: token  && token.builtOn !== "" ? Style.svg("tiny/" + RootStore.getNetworkIconUrl(token.builtOn)) : ""
                            tagPrimaryLabel.text: token && token.builtOn !== "" ? RootStore.getNetworkName(token.builtOn) : "---"
                            tagSecondaryLabel.text: token && token.smartContractAddress !== "" ? token.smartContractAddress : "---"
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.builtOn !== "" && token.smartContractAddress !== ""
                        }
                    }
                }
            }
        }
    }
}
