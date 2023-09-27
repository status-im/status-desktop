import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.controls.chat 1.0
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string selectedTokenSymbol
    property string currentCurrency

    property var bestRoutes
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property var formatCurrencyAmount: function () {}
    property var getNetworkName: function () {}

    width: parent.width
    height: visible ? advancedGasSelector.height + Style.current.halfPadding : 0

    Column {
        id: advancedGasSelector
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 10

        spacing: Style.current.halfPadding

        // Normal transaction
        Repeater {
            model: root.bestRoutes
            StatusListItem {
                id: listItem
                color: Theme.palette.statusListItem.backgroundColor
                width: parent.width
                asset.name: "tiny/gas"
                asset.color: Theme.palette.directColor1
                statusListItemIcon.active: true
                statusListItemIcon.opacity: modelData.isFirstSimpleTx
                title: qsTr("%1 transaction fee").arg(root.getNetworkName(modelData.fromNetwork))
                subTitle: root.formatCurrencyAmount(totalGasAmountEth, "ETH")
                property double totalGasAmountEth: {
                    let maxFees = modelData.gasFees.maxFeePerGasM
                    let gasPrice = modelData.gasFees.eip1559Enabled ? maxFees : modelData.gasFees.gasPrice
                    return root.getGasEthValue(gasPrice , modelData.gasAmount)
                }
                property double totalGasAmountFiat: root.getFiatValue(totalGasAmountEth, "ETH", root.currentCurrency)
                statusListItemSubTitle.width: listItem.width/2 - Style.current.smallPadding
                statusListItemSubTitle.elide: Text.ElideMiddle
                statusListItemSubTitle.wrapMode: Text.NoWrap
                components: [
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text: root.formatCurrencyAmount(totalGasAmountFiat, root.currentCurrency)
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                    }
                ]
            }
        }

        // Approval transaction
        Repeater {
            model: root.bestRoutes
            StatusListItem {
                id: listItem1
                color: Theme.palette.statusListItem.backgroundColor
                width: parent.width
                asset.name: "tiny/checkmark"
                asset.color: Theme.palette.directColor1
                statusListItemIcon.active: true
                statusListItemIcon.opacity: modelData.isFirstSimpleTx
                title: qsTr("Approve %1 %2 Bridge").arg(root.getNetworkName(modelData.fromNetwork)).arg(root.selectedTokenSymbol)
                property double approvalGasFees: modelData.approvalGasFees
                property string approvalGasFeesSymbol: "ETH"
                property double approvalGasFeesFiat: root.getFiatValue(approvalGasFees, approvalGasFeesSymbol, root.currentCurrency)
                subTitle: root.formatCurrencyAmount(approvalGasFees, approvalGasFeesSymbol)
                statusListItemSubTitle.width: listItem1.width/2 - Style.current.smallPadding
                statusListItemSubTitle.elide: Text.ElideMiddle
                statusListItemSubTitle.wrapMode: Text.NoWrap
                visible: modelData.approvalRequired
                components: [
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text:  root.formatCurrencyAmount(approvalGasFeesFiat, root.currentCurrency)
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                    }
                ]
            }
        }

        // Bridge
        Repeater {
            id: bridgeRepeater
            model: root.bestRoutes
            delegate: StatusListItem {
                id: listItem2
                color: Theme.palette.statusListItem.backgroundColor
                width: parent.width
                asset.name: "tiny/bridge"
                asset.color: Theme.palette.directColor1
                statusListItemIcon.active: true
                statusListItemIcon.opacity: modelData.isFirstBridgeTx
                title: qsTr("%1 -> %2 bridge").arg(root.getNetworkName(modelData.fromNetwork)).arg(root.getNetworkName(modelData.toNetwork))
                property double tokenFees: modelData.tokenFees
                property double tokenFeesFiat: root.getFiatValue(tokenFees, root.selectedTokenSymbol, root.currentCurrency)
                subTitle: root.formatCurrencyAmount(tokenFees, root.selectedTokenSymbol)
                visible: modelData.bridgeName !== "Transfer"
                statusListItemSubTitle.width: 100
                statusListItemSubTitle.elide: Text.ElideMiddle
                components: [
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text: root.formatCurrencyAmount(tokenFeesFiat, root.currentCurrency)
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                    }
                ]
            }
        }
    }
}
