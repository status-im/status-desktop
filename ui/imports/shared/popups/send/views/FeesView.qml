import QtQuick
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme

import utils

import shared.stores
import shared.stores.send as SharedSendStores

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
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    font.pixelSize: Theme.primaryTextFontSize
                    text: qsTr("Fees")
                    wrapMode: Text.WordWrap
                }
                StatusBaseText {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padding
                    id: totalFeesAdvanced
                    text: root.isLoading ? "..." : root.currencyStore.formatCurrencyAmount(root.gasFiatAmount, root.currencyStore.currentCurrency)
                    font.pixelSize: Theme.primaryTextFontSize
                    color: Theme.palette.directColor1
                    visible: !root.isLoading && !!root.bestRoutes && root.bestRoutes !== undefined && root.bestRoutes.count > 0
                }
            }
            GasSelector {
                id: gasSelector
                width: parent.width
                getGasNativeCryptoValue: function(gasPrice, gasAmount, chainId) {
                    return Utils.calculateGasCost(chainId, gasPrice, gasAmount)
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
