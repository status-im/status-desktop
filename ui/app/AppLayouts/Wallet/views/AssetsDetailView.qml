import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0
import shared.controls 1.0
import shared.stores 1.0 as SharedStores

import AppLayouts.Wallet.helpers 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores

import SortFilterProxyModel 0.2

import "../controls"

/// \beware: heavy shortcuts here, refactor to match the requirements when touching this again
/// \todo split into token history and balance views; they have different requirements that introduce unnecessary complexity
/// \todo take a declarative approach, move logic into the typed backend and remove multiple source of truth (e.g. time ranges)
Item {
    id: root

    property var token: ({})

    property WalletStores.TokensStore tokensStore
    property SharedStores.CurrenciesStore currencyStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property var allNetworksModel
    property var networkFilters
    onNetworkFiltersChanged: d.forceRefreshBalanceStore = true
    /*required*/ property string address: ""

    TokenBalanceHistoryData {
        id: balanceData
    }

    TokenMarketValuesData {
        id: marketValueData
    }

    QtObject {
        id: d

        readonly property string symbol: !!root.token? root.token.symbol?? "" : ""
        property bool marketDetailsLoading: !!root.token? root.token.marketDetailsLoading?? false : false
        property bool tokenDetailsLoading: !!root.token? root.token.detailsLoading?? false: false
        property bool isCommunityAsset: !!root.token && !!token.communityId

        readonly property LeftJoinModel addressPerChainModel: LeftJoinModel {
            leftModel: token && token.addressPerChain ? token.addressPerChain: null
            rightModel: root.allNetworksModel
            joinRole: "chainId"
        }

        property bool forceRefreshBalanceStore: false
        readonly property var splitAddresses: root.networkFilters.split(":")

        readonly property SortFilterProxyModel enabledNetworksModel: SortFilterProxyModel {
            sourceModel: root.allNetworksModel
            filters: ValueFilter {
                roleName: "isEnabled"
                value: true
            }
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

            marketValueData.setTimeAndValueData(response.historicalData, response.range)
        }
    }

    AssetsDetailsHeader {
        id: tokenDetailsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        asset.name: {
            if (!token)
                return ""
            if (token.image)
                return token.image
            if (token.symbol)
                return Theme.png("tokens/%1".arg(token.symbol))
            return ""
        }
        asset.isImage: true
        primaryText: token && token.name ? token.name : Constants.dummyText
        secondaryText: token ? token.balanceText : Constants.dummyText
        tertiaryText: {
            if (!d.isCommunityAsset) {
                let totalCurrencyBalance = token ? token.balance * token.marketPrice : 0
                return root.currencyStore.formatCurrencyAmount(totalCurrencyBalance, root.currencyStore.currentCurrency)
            }
            return ""
        }
        decimals: token && token.decimals ? token.decimals : 4
        balances: token && token.balances ? token.balances: null
        networksModel: d.enabledNetworksModel
        isLoading: d.marketDetailsLoading
        address: root.address
        errorTooltipText: token && token.balances ? networkConnectionStore.getBlockchainNetworkDownTextForToken(token.balances): ""
        formatBalance: function(balance){
            return LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrencyAmount(balance, token.symbol))
        }
        communityTag.visible: d.isCommunityAsset
        communityTag.tagPrimaryLabel.text: d.isCommunityAsset ? token.communityName: ""
        communityTag.asset.name: d.isCommunityAsset ? token && !!token.communityImage ? token.communityImage : "" : ""
        communityTag.asset.isImage: true
    }

    enum GraphType {
        Price = 0,
        Balance
    }

    StatusScrollView {
        id: scrollView
        anchors.top: tokenDetailsHeader.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 47

        width: parent.width
        contentWidth: availableWidth
        padding: 0

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 40

            Loader {
                id: graphDetailLoader
                Layout.fillWidth: true
                Layout.preferredHeight: 290
                active: root.visible
                sourceComponent: StatusChartPanel {
                    id: graphDetail

                    property int selectedGraphType: AssetsDetailView.GraphType.Price
                    property TokenMarketValuesData selectedStore: marketValueData

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
                        {text: qsTr("Price"), enabled: true, id: AssetsDetailView.GraphType.Price, visible: !d.isCommunityAsset},
                        {text: qsTr("Balance"), enabled: true, id: AssetsDetailView.GraphType.Balance, visible: true},
                    ]
                    defaultTimeRangeIndexShown: ChartDataBase.TimeRange.All
                    timeRangeModel: dataReady() && selectedStore.timeRangeTabsModel
                    onHeaderTabClicked: (privateIdentifier, isTimeRange) => {
                                            if(!isTimeRange && graphDetail.selectedGraphType !== privateIdentifier) {
                                                graphDetail.selectedGraphType = privateIdentifier
                                            }

                                            if(graphDetail.selectedGraphType === AssetsDetailView.GraphType.Balance) {
                                                graphDetail.updateBalanceStore()
                                            }

                                            if(!isTimeRange) {
                                                graphDetail.selectedStore = graphDetail.selectedGraphType === AssetsDetailView.GraphType.Price ? marketValueData : balanceData
                                            }

                                            chart.refresh()
                                        }

                    readonly property var dateToShortLabel: function (value) {
                        const range = balanceData.timeRangeStrToEnum(graphDetail.selectedTimeRange)
                        return range === ChartDataBase.TimeRange.Weekly || range === ChartDataBase.TimeRange.Monthly ?
                                    LocaleUtils.getDayMonth(value) :
                                    LocaleUtils.getMonthYear(value)
                    }
                    chart.type: 'line'
                    chart.labels: root.tokensStore.marketHistoryIsLoading ? [] : graphDetail.labelsData
                    chart.datasets: {
                        return [{
                            xAxisId: 'x-axis-1',
                            yAxisId: 'y-axis-1',
                            backgroundColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 0.2)' : 'rgba(67, 96, 223, 0.2)',
                            borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                            borderWidth: graphDetail.selectedGraphType === AssetsDetailView.GraphType.Price ? 3 : 2,
                            pointRadius: 0,
                            data: root.tokensStore.marketHistoryIsLoading ? [] : graphDetail.dataRange,
                            parsing: false,
                        }]
                    }

                    chart.options: {
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
                                        return root.currencyStore.formatCurrencyAmount(value, root.currencyStore.currentCurrency)
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

                                        const value = root.currencyStore.formatCurrencyAmount(
                                                        tooltipItem.yLabel, root.currencyStore.currentCurrency)

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
                        active: root.tokensStore.marketHistoryIsLoading
                    }

                    function updateBalanceStore() {
                        let selectedTimeRangeEnum = balanceData.timeRangeStrToEnum(graphDetail.selectedTimeRange)

                        let currencySymbol = root.currencyStore.currentCurrency

                        if(!balanceData.hasData(root.address, token.symbol, currencySymbol, selectedTimeRangeEnum) || d.forceRefreshBalanceStore) {
                            root.tokensStore.fetchHistoricalBalanceForTokenAsJson(root.address, token.symbol, currencySymbol, selectedTimeRangeEnum)
                        }
                    }

                    Connections {
                        target: balanceData
                        function onNewDataReady(address, tokenSymbol, currencySymbol, timeRange) {
                            d.forceRefreshBalanceStore = false
                            if (timeRange === balanceData.timeRangeStrToEnum(graphDetail.selectedTimeRange)) {
                                chart.refresh()
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

            RowLayout {
                Layout.fillWidth: true
                visible: !d.isCommunityAsset
                InformationTile {
                    maxWidth: parent.width
                    objectName: "marketCapInformationTile"
                    primaryText: qsTr("Market Cap")
                    secondaryText: token && token.marketDetails && token.marketDetails.marketCap ? LocaleUtils.currencyAmountToLocaleString(token.marketDetails.marketCap) : Constants.dummyText
                    isLoading: d.marketDetailsLoading
                }
                InformationTile {
                    maxWidth: parent.width
                    objectName: "dayLowInformationTile"
                    primaryText: qsTr("Day Low")
                    secondaryText: token && token.marketDetails && token.marketDetails.lowDay ? LocaleUtils.currencyAmountToLocaleString(token.marketDetails.lowDay) : Constants.dummyText
                    isLoading: d.marketDetailsLoading
                }
                InformationTile {
                    maxWidth: parent.width
                    objectName: "dayHighInformationTile"
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
                    objectName: "hourInformationTile"
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
                    objectName: "dayInformationTile"
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
                    objectName: "24HoursInformationTile"
                    secondaryText: "%1%".arg(LocaleUtils.numberToLocaleString(changePct24hour, 2))
                    secondaryLabel.customColor: changePct24hour === 0 ? Theme.palette.directColor1 :
                                                                        changePct24hour < 0 ? Theme.palette.dangerColor1 :
                                                                                              Theme.palette.successColor1
                    isLoading: d.marketDetailsLoading
                }
            }

            Flow {
                id: detailsFlow

                readonly property bool isOverflowing:  detailsFlow.width - websiteBlock.width - tokenDescriptionText.width < 24

                Layout.fillWidth: true
                spacing: 24

                StatusTabBar {
                    width: parent.width
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Overview")
                    }
                    visible: tokenDescriptionText.visible
                }

                StatusTextWithLoadingState {
                    id: tokenDescriptionText
                    width: Math.max(536 , scrollView.availableWidth - websiteBlock.width - 24)

                    font.pixelSize: 15
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    text: token && token.description ? token.description : d.tokenDetailsLoading ? Constants.dummyText: ""
                    customColor: Theme.palette.directColor1
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    textFormat: Qt.RichText
                    loading: d.tokenDetailsLoading
                    visible: !!text
                }

                GridLayout{
                    columnSpacing: 10
                    rowSpacing: 10
                    flow: detailsFlow.isOverflowing ? GridLayout.LeftToRight: GridLayout.TopToBottom
                    InformationTileAssetDetails {
                        id: websiteBlock
                        Layout.preferredWidth: 272
                        visible: !d.isCommunityAsset
                        primaryText: qsTr("Website")
                        content: InformationTag {
                            asset.name : "browser"
                            tagPrimaryLabel.text: SQUtils.Utils.stripHttpsAndwwwFromUrl(token.websiteUrl)
                            visible: typeof token != "undefined" && token && token.websiteUrl !== ""
                            customBackground: Component {
                                Rectangle {
                                    color: Theme.palette.baseColor2
                                    border.width: 1
                                    border.color: "transparent"
                                    radius: 36
                                }
                            }
                            StatusMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.openLink(token.websiteUrl)
                            }
                        }
                    }

                    InformationTileAssetDetails {
                        Layout.preferredWidth: 272
                        visible:  d.isCommunityAsset
                        primaryText: qsTr("Minted by")
                        content: InformationTag {
                            tagPrimaryLabel.text: token && token.communityName ? token.communityName : ""
                            asset.name: token && token.communityImage ? token.communityImage : ""
                            asset.isImage: true
                            customBackground: Component {
                                Rectangle {
                                    color: Theme.palette.baseColor2
                                    border.width: 1
                                    border.color: "transparent"
                                    radius: 36
                                }
                            }
                            StatusMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.switchToCommunity(token.communityId)
                            }
                        }
                    }

                    InformationTileAssetDetails {
                        Layout.minimumWidth: 272
                        Layout.preferredWidth: implicitWidth
                        primaryText: qsTr("Contract")
                        content: GridLayout {
                            columnSpacing: 10
                            rowSpacing: 10
                            flow: detailsFlow.isOverflowing ? GridLayout.LeftToRight : GridLayout.TopToBottom
                            Repeater {
                                model: SortFilterProxyModel {
                                    sourceModel: d.addressPerChainModel
                                    filters: FastExpressionFilter {
                                        expression: d.splitAddresses.includes(model.chainId+"")
                                        expectedRoles: ["chainId"]
                                    }
                                }
                                delegate: InformationTag {
                                    asset.name: Theme.svg(model.iconUrl)
                                    asset.isImage: true
                                    tagPrimaryLabel.text: model.chainName
                                    tagSecondaryLabel.text: SQUtils.Utils.elideAndFormatWalletAddress(model.address)
                                    customBackground: Component {
                                        Rectangle {
                                            color: Theme.palette.baseColor2
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
}
