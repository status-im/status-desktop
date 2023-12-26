import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0
import shared.controls 1.0
import shared.stores 1.0

import SortFilterProxyModel 0.2

/// \beware: heavy shortcuts here, refactor to match the requirements when touching this again
/// \todo split into token history and balance views; they have different requirements that introduce unnecessary complexity
/// \todo take a declarative approach, move logic into the typed backend and remove multiple source of truth (e.g. time ranges)
Item {
    id: root

    property var token: ({})
    property var currencyStore
    property var networkConnectionStore
    property var allNetworksModel
    property var networkFilters
    /*required*/ property string address: ""
    property bool showAllAccounts: false
    property TokenBalanceHistoryStore balanceStore: TokenBalanceHistoryStore {}

    QtObject {
        id: d
        property var marketValueStore : RootStore.marketValueStore
        readonly property string symbol: !!root.token? root.token.symbol?? "" : ""
        property bool marketDetailsLoading: !!root.token? root.token.marketDetailsLoading?? false : false
        property bool tokenDetailsLoading: !!root.token? root.token.detailsLoading?? false: false

        readonly property LeftJoinModel addressPerChainModel: LeftJoinModel {
            leftModel: token && token.addressPerChain ? token.addressPerChain: null
            rightModel: root.allNetworksModel
            joinRole: "chainId"
        }
    }

    Connections {
        target: walletSectionAllTokens
        function onTokenHistoricalDataReady(tokenDetails: string) {
            let response = JSON.parse(tokenDetails)
            if (response === null) {
                console.debug("error parsing json message for tokenHistoricalDataReady")
                return
            }
            if(response.historicalData === null || response.historicalData <= 0)
                return

            d.marketValueStore.setTimeAndValueData(response.historicalData, response.range)
        }
    }

    AssetsDetailsHeader {
        id: tokenDetailsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        asset.name: token && token.symbol ? Style.png("tokens/%1".arg(token.symbol)) : ""
        asset.isImage: true
        primaryText: token && token.name ? token.name : Constants.dummyText
        secondaryText: token ? LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrencyAmount(token.currentBalance, token.symbol)) : Constants.dummyText
        tertiaryText: {
            let totalCurrencyBalance = token && token.currentCurrencyBalance ? token.currentCurrencyBalance : 0
            return LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrentCurrencyAmount(totalCurrencyBalance))
        }
        decimals: token && token.decimals ? token.decimals : 4
        balances: token && token.balances ? token.balances: null
        allNetworksModel: root.allNetworksModel
        isLoading: d.marketDetailsLoading
        errorTooltipText: token && token.balances ? networkConnectionStore.getBlockchainNetworkDownTextForToken(token.balances): ""
        formatBalance: function(balance){
            return LocaleUtils.currencyAmountToLocaleString(currencyStore.getCurrencyAmount(balance, token.symbol))
        }
    }

    enum GraphType {
        Price = 0,
        Balance
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

            property int selectedGraphType: AssetsDetailView.GraphType.Price
            property var selectedStore: d.marketValueStore

            function dataReady() {
                return typeof selectedStore != "undefined"
            }
            function timeRangeSelected() {
                return dataReady() && graphDetail.timeRangeTabBarIndex >= 0 && graphDetail.selectedTimeRange.length > 0
            }

            readonly property var labelsData: {
                return timeRangeSelected()
                        ? selectedStore.timeRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange]
                        : []
            }
            readonly property var dataRange: {
                return timeRangeSelected()
                        ? selectedStore.dataRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange]
                        : []
            }
            readonly property var maxTicksLimit: {
                return timeRangeSelected() && typeof selectedStore.maxTicks != "undefined"
                        ? selectedStore.maxTicks[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange]
                        : 0
            }

            graphsModel: [
                {text: qsTr("Price"), enabled: true, id: AssetsDetailView.GraphType.Price},
                {text: qsTr("Balance"), enabled: true, id: AssetsDetailView.GraphType.Balance},
            ]
            defaultTimeRangeIndexShown: ChartStoreBase.TimeRange.All
            timeRangeModel: dataReady() && selectedStore.timeRangeTabsModel
            onHeaderTabClicked: (privateIdentifier, isTimeRange) => {
                                    if(!isTimeRange && graphDetail.selectedGraphType !== privateIdentifier) {
                                        graphDetail.selectedGraphType = privateIdentifier
                                    }

                                    if(graphDetail.selectedGraphType === AssetsDetailView.GraphType.Balance) {
                                        graphDetail.updateBalanceStore()
                                    }

                                    if(!isTimeRange) {
                                        graphDetail.selectedStore = graphDetail.selectedGraphType === AssetsDetailView.GraphType.Price ? d.marketValueStore : balanceStore
                                    }

                                    chart.animateToNewData()
                                }

            readonly property var dateToShortLabel: function (value) {
                const range = balanceStore.timeRangeStrToEnum(graphDetail.selectedTimeRange)
                return range === ChartStoreBase.TimeRange.Weekly || range === ChartStoreBase.TimeRange.Monthly ?
                            LocaleUtils.getDayMonth(value) :
                            LocaleUtils.getMonthYear(value)
            }
            chart.chartType: 'line'
            chart.chartData: {
                return {
                    labels: RootStore.marketHistoryIsLoading ? [] : graphDetail.labelsData,
                    datasets: [{
                            xAxisId: 'x-axis-1',
                            yAxisId: 'y-axis-1',
                            backgroundColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 0.2)' : 'rgba(67, 96, 223, 0.2)',
                            borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                            borderWidth: graphDetail.selectedGraphType === AssetsDetailView.GraphType.Price ? 3 : 2,
                            pointRadius: 0,
                            data: RootStore.marketHistoryIsLoading ? [] : graphDetail.dataRange,
                            parsing: false,
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
                    elements: {
                        line: {
                            cubicInterpolationMode: 'monotone' // without it interpolation makes the line too curvy that can extend horizontally farther then data points
                        }
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
                        format: {
                            enabled: graphDetail.selectedGraphType === AssetsDetailView.GraphType.Balance,
                            callback: function (value) {
                                return graphDetail.dateToShortLabel(value)
                            },
                            valueCallback: function(value) {
                                return LocaleUtils.currencyAmountToLocaleString({ amount: value, symbol: RootStore.currencyStore.currentCurrencySymbol, displayDecimals: 2 })
                            }
                        },
                        intersect: false,
                        displayColors: false,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                let label = data.datasets[tooltipItem.datasetIndex].label || '';
                                if (label) {
                                    label += ': ';
                                }

                                if (graphDetail.selectedGraphType === AssetsDetailView.GraphType.Balance)
                                    return label + tooltipItem.yLabel // already formatted in tooltips.value.callback

                                const value = LocaleUtils.currencyAmountToLocaleString({ amount: tooltipItem.yLabel, symbol: RootStore.currencyStore.currentCurrencySymbol, displayDecimals: 2 })
                                return label + value
                            }
                        }
                    },
                    scales: {
                        labelFormat: {
                            callback: function (value) {
                                return graphDetail.dateToShortLabel(value)
                            },
                            enabled: graphDetail.selectedGraphType === AssetsDetailView.GraphType.Balance,
                        },
                        xAxes: [{
                                id: 'x-axis-1',
                                position: 'bottom',
                                type: graphDetail.selectedGraphType === AssetsDetailView.GraphType.Price ? 'category' : 'time',
                                gridLines: {
                                    drawOnChartArea: false,
                                    drawBorder: false,
                                    drawTicks: false,
                                },
                                ticks: {
                                    fontSize: 10,
                                    fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                                    padding: 16,
                                    maxRotation: 0,
                                    minRotation: 0,
                                    maxTicksLimit: graphDetail.maxTicksLimit,
                                },
                                time: {
                                    minUnit: 'day' // for '7days' timeframe, otherwise labels are '10PM', '10AM', '10PM', etc
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
                                afterDataLimits: (axis) => {
                                    if(axis.min < 0)
                                    axis.min = 0;
                                },
                                ticks: {
                                    fontSize: 10,
                                    fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                                    padding: 8,
                                    callback: function(value, index, ticks) {
                                        return LocaleUtils.numberToLocaleString(value)
                                    },
                                }
                            }]
                    }
                }
            }

            LoadingGraphView {
                anchors.fill: chart
                active: RootStore.marketHistoryIsLoading
            }

            function updateBalanceStore() {
                let selectedTimeRangeEnum = balanceStore.timeRangeStrToEnum(graphDetail.selectedTimeRange)

                let currencySymbol = RootStore.currencyStore.currentCurrency
                if(!balanceStore.hasData(root.address, root.showAllAccounts, token.symbol, currencySymbol, selectedTimeRangeEnum)) {
                    RootStore.fetchHistoricalBalanceForTokenAsJson(root.address, root.showAllAccounts, token.symbol, currencySymbol, selectedTimeRangeEnum)
                }
            }

            Connections {
                target: balanceStore
                function onNewDataReady(address, tokenSymbol, currencySymbol, timeRange) {
                    if (timeRange === timeRangeStrToEnum(graphDetail.selectedTimeRange)) {
                        chart.updateToNewData()
                    }
                }
            }

            Connections {
                target: root
                function onAddressChanged() { graphDetail.updateBalanceStore() }
            }

            Connections {
                target: d
                function onSymbolChanged() { if (d.symbol) graphDetail.updateBalanceStore() }
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
                secondaryText: token && token.marketDetails && token.marketDetails.marketCap ? LocaleUtils.currencyAmountToLocaleString(token.marketDetails.marketCap) : Constants.dummyText
                isLoading: d.marketDetailsLoading
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day Low")
                secondaryText: token && token.marketDetails && token.marketDetails.lowDay ? LocaleUtils.currencyAmountToLocaleString(token.marketDetails.lowDay) : Constants.dummyText
                isLoading: d.marketDetailsLoading
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day High")
                secondaryText: token && token.marketDetails && token.marketDetails.highDay ? LocaleUtils.currencyAmountToLocaleString(token.marketDetails.highDay) : Constants.dummyText
                isLoading: d.marketDetailsLoading
            }
            Item {
                Layout.fillWidth: true
            }
            InformationTile {
                readonly property double changePctHour: token && token.marketDetails ? token.marketDetails.changePctHour : 0
                maxWidth: parent.width
                primaryText: qsTr("Hour")
                secondaryText: "%1%".arg(LocaleUtils.numberToLocaleString(changePctHour, 2))
                secondaryLabel.customColor: changePctHour === 0 ? Theme.palette.directColor1 :
                                                                  changePctHour < 0 ? Theme.palette.dangerColor1 :
                                                                                      Theme.palette.successColor1
                isLoading: d.marketDetailsLoading
            }
            InformationTile {
                readonly property double changePctDay: token && token.marketDetails ? token.marketDetails.changePctDay : 0
                maxWidth: parent.width
                primaryText: qsTr("Day")
                secondaryText: "%1%".arg(LocaleUtils.numberToLocaleString(changePctDay, 2))
                secondaryLabel.customColor: changePctDay === 0 ? Theme.palette.directColor1 :
                                                                 changePctDay < 0 ? Theme.palette.dangerColor1 :
                                                                                    Theme.palette.successColor1
                isLoading: d.marketDetailsLoading
            }
            InformationTile {
                readonly property double changePct24hour: token && token.marketDetails ? token.marketDetails.changePct24hour : 0
                maxWidth: parent.width
                primaryText: qsTr("24 Hours")
                secondaryText: "%1%".arg(LocaleUtils.numberToLocaleString(changePct24hour, 2))
                secondaryLabel.customColor: changePct24hour === 0 ? Theme.palette.directColor1 :
                                                                    changePct24hour < 0 ? Theme.palette.dangerColor1 :
                                                                                          Theme.palette.successColor1
                isLoading: d.marketDetailsLoading
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
                topPadding: 8
                bottomPadding: 8
                contentWidth: availableWidth
                Flow {
                    id: detailsFlow

                    readonly property bool isOverflowing:  detailsFlow.width - tagsLayout.width - tokenDescriptionText.width < 24

                    spacing: 24

                    width: scrollView.availableWidth
                    StatusTextWithLoadingState {
                        id: tokenDescriptionText
                        width: Math.max(536 , scrollView.availableWidth - tagsLayout.width - 24)

                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        text: token && token.description ? token.description : Constants.dummyText
                        customColor: Theme.palette.directColor1
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        textFormat: Qt.RichText
                        loading: d.tokenDetailsLoading
                    }
                    ColumnLayout {
                        id: tagsLayout
                        spacing: 10
                        InformationTag {
                            id: website
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight
                            iconAsset.icon: "browser"
                            tagPrimaryLabel.text: qsTr("Website")
                            visible: typeof token != "undefined" && token && token.websiteUrl !== ""
                            customBackground: Component {
                                Rectangle {
                                    color: Theme.palette.baseColor2
                                    border.width: 1
                                    border.color: "transparent"
                                    radius: 36
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.openLink(token.websiteUrl)
                            }
                        }

                        /* TODO :: Issue with not being able to see correct balances after switching assets will be fixed under
                        https://github.com/status-im/status-desktop/issues/12912 */
                        Repeater {
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight
                            model: SortFilterProxyModel {
                                sourceModel: d.addressPerChainModel
                                filters: ExpressionFilter {
                                    expression: root.networkFilters.split(":").includes(model.chainId+"")
                                }
                            }
                            InformationTag {
                                image.source: Style.svg("tiny/" + model.iconUrl)
                                tagPrimaryLabel.text: model.chainName
                                tagSecondaryLabel.text: model.address
                                customBackground: Component {
                                    Rectangle {
                                        color: Theme.palette.baseColor2
                                        border.width: 1
                                        border.color: "transparent"
                                        radius: 36
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
