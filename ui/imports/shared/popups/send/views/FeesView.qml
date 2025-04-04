import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.stores 1.0
import shared.stores.send 1.0 as SharedSendStores

import "../controls"

Rectangle {
    id: root

    property double gasFiatAmount
    property bool isLoading: false
    property var bestRoutes
    property SharedSendStores.TransactionStore store
    property CurrenciesStore currencyStore: store.currencyStore
    property var selectedAsset
    property int errorType: Constants.NoError

    radius: 13
    color: Theme.palette.indirectColor1
    implicitHeight: columnLayout.height + feesIcon.height

    RowLayout {
        id: feesLayout
        spacing: 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Theme.padding

        StatusRoundIcon {
            id: feesIcon
            Layout.alignment: Qt.AlignTop
            radius: 8
            asset.name: "fees"
            asset.color: Theme.palette.directColor1
        }
        Column {
            id: columnLayout
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredWidth: root.width - feesIcon.width - Theme.xlPadding
            spacing: isLoading ? 4 : 0
            Item {
                width: parent.width
                height: childrenRect.height
                StatusBaseText {
                    id: text
                    anchors.left: parent.left
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    text: qsTr("Fees")
                    wrapMode: Text.WordWrap
                }
                StatusBaseText {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padding
                    id: totalFeesAdvanced
                    text: root.isLoading ? "..." : root.currencyStore.formatCurrencyAmount(root.gasFiatAmount, root.currencyStore.currentCurrency)
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    visible: !root.isLoading && !!root.bestRoutes && root.bestRoutes !== undefined && root.bestRoutes.count > 0
                }
            }
            GasSelector {
                id: gasSelector
                width: parent.width
                getGasNativeCryptoValue: function(gasPrice, gasAmount) {
                    return Utils.getGasDecimalValue(root.selectedAsset.chainId, gasPrice, gasAmount)
                }
                getFiatValue: root.currencyStore.getFiatValue
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                currentCurrency: root.currencyStore.currentCurrency
                visible: root.errorType === Constants.NoError && !root.isLoading
                bestRoutes: !root.isLoading && !!root.bestRoutes? root.bestRoutes : null
                selectedAsset: root.selectedAsset
                getNetworkName: root.store.getNetworkName
            }
            GasValidator {
                id: gasValidator
                width: parent.width
                isLoading: root.isLoading
                errorType: root.errorType
            }
        }
    }
}
