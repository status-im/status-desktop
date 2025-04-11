import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.Market.controls 1.0

StatusSectionLayout {
    id: root

    /** required property representing token model **/
    required property var tokensModel
    /** required property representing loading state **/
    required property bool loading
    /** required property representing total number of tokens **/
    required property int totalTokensCount
    /** required property representing currency symbol $/£/€ etc... **/
    required property string currencySymbol
    required property var fnFormatCurrencyAmount

    // TODO: remove this code its only to show a dummy list in the app till the backend is ready
    property int startIndex: listView.footerItem.startIndex
    // TODO: remove this code its only to show a dummy list in the app till the backend is ready
    property int endIndex: listView.footerItem.endIndex

    /** signal to request the launch of Swap Modal **/
    signal requestLaunchSwap()
    /** signal to request fetching tokens as per selected page and page size **/
    signal fetchMarketTokens(int pageNumber, int pageSize)

    // TODO:: Implement resetting token list view
    function resetView() {}

    QtObject {
        id: d
        readonly property int pageSize: 100
    }

    Component.onCompleted: {
        root.fetchMarketTokens(0, d.pageSize)
    }

    centerPanel: ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 64
        anchors.leftMargin: 64
        spacing: 18

        // Header
        RowLayout {
            Layout.alignment: Qt.AlignTop
            StatusBaseText {
                objectName: "heading"
                text: qsTr("Market")
                font.weight: Font.Bold
                font.pixelSize: 28
            }
            Item { Layout.fillWidth: true }
            StatusButton {
                objectName: "swapButton"
                text: qsTr("Swap")
                icon.name: "swap"
                type: StatusBaseButton.Type.Primary
                onClicked: root.requestLaunchSwap()
            }
        }

        StatusListView {
            id: listView
            objectName: "tokensList"

            Layout.fillWidth: true
            Layout.fillHeight: true

            headerPositioning: ListView.OverlayHeader
            header: MarketTokenHeader {
                width: listView.width
            }

            footer: MarketFooter {
                objectName: "marketFooter"
                width: listView.width
                pageSize: d.pageSize
                totalCount: root.totalTokensCount
                onSwitchPage: root.fetchMarketTokens(pageNumber, d.pageSize)
            }

            model: root.loading ? loadingModel: regularModel
        }

        // loading items model
        DelegateModel {
            id: loadingModel

            objectName: "loadingModel"

            model: d.pageSize

            delegate: MarketLoadingTokenDelegate {
                width: listView.width
            }
        }

        // tokens model
        DelegateModel {
            id: regularModel

            objectName: "regularModel"

            model: root.tokensModel

            delegate: MarketTokenDelegate {
                width: listView.width

                indexString: root.startIndex + index
                tokenName: model.name
                tokenSymbol: model.symbol
                iconSource: model.image
                price: "%1%2"
                .arg(root.currencySymbol)
                .arg(root.fnFormatCurrencyAmount(model.currentPrice, {noSymbol: true}))
                changePct24Hour: qsTr("%1 %2%", "[up/down/none character depending on value sign] [localized percentage value]%")
                .arg(WalletUtils.getUpDownTriangle(model.priceChangePercentage24h))
                .arg(LocaleUtils.numberToLocaleString(model.priceChangePercentage24h, 2))
                changePct24HourColor: WalletUtils.getChangePct24HourColor(model.priceChangePercentage24h)
                volume24Hour: "%1%2"
                .arg(root.currencySymbol)
                .arg(root.fnFormatCurrencyAmount(model.totalVolume, {noSymbol: true}))
                marketCap: "%1%2"
                .arg(root.currencySymbol)
                .arg(root.fnFormatCurrencyAmount(model.marketCap, {noSymbol: true}))
            }
        }
    }
}
