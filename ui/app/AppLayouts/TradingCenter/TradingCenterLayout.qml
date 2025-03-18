import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.TradingCenter.controls 1.0

StatusSectionLayout {
    id: root

    /** required property representing token model **/
    required property var tokensModel
    /** required function to get formatted currency amount **/
    required property var formatCurrencyAmount
    /** required property representing loading state **/
    required property bool loading

    /** signal to request the launch of Swap Modal **/
    signal requestLaunchSwap()

    // TODO:: Implement resetting token list view
    function resetView() {}

    QtObject {
        id: d
        readonly property int pageSize: 100
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
                text: qsTr("Trading")
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

        ListView {
            id: listView
            objectName: "tokensList"

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            headerPositioning: ListView.OverlayHeader
            header: TradingCenterTokenHeader {
                width: listView.width
            }

            model: root.loading ? loadingModel: regularModel
        }

        // loading items model
        DelegateModel {
            id: loadingModel

            objectName: "loadingModel"

            model: d.pageSize

            delegate: TradingCenterLoadingTokenDelegate {
                width: listView.width
            }
        }

        // tokens model
        DelegateModel {
            id: regularModel

            objectName: "regularModel"

            model: root.tokensModel

            delegate: TradingCenterTokenDelegate {
                width: listView.width

                tokenName: model.name
                tokenSymbol: model.symbol
                iconSource: Constants.tokenIcon(model.symbol)
                price: root.formatCurrencyAmount(model.marketDetails.currencyPrice.amount)
                changePct24Hour: qsTr("%1 %2%", "[up/down/none character depending on value sign] [localized percentage value]%")
                .arg(WalletUtils.getUpDownTriangle(model.marketDetails.changePct24hour))
                .arg(LocaleUtils.numberToLocaleString(model.marketDetails.changePct24hour, 2))
                changePct24HourColor: WalletUtils.getChangePct24HourColor(model.marketDetails.changePct24hour)
                volume24Hour: "--"
                marketCap: LocaleUtils.currencyAmountToLocaleString(model.marketDetails.marketCap)
            }
        }
    }
}
