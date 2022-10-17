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
    property string currentCurrencySymbol
    property bool advancedOrCustomMode: false

    property var bestRoutes: []
    property var estimatedGasFeesTime: []

    property int selectedPriority: 1
    property double selectedGasEthValue
    property string selectedGasFiatValue
    property string selectedTimeEstimate

    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}

    enum Priority {
        SLOW, // 0
        OPTIMAL, // 1
        FAST // 2
    }

    enum EstimatedTime {
        Unknown = 0,
        LessThanOneMin,
        LessThanThreeMins,
        LessThanFiveMins,
        MoreThanFiveMins
    }

    QtObject {
        id: d
        function getLabelForEstimatedTxTime(estimatedFlag) {
            switch(estimatedFlag) {
            case GasSelector.EstimatedTime.Unknown:
                return qsTr("~ Unknown")
            case GasSelector.EstimatedTime.LessThanOneMin :
                return qsTr("< 1 minute")
            case GasSelector.EstimatedTime.LessThanThreeMins :
                return qsTr("< 3 minutes")
            case GasSelector.EstimatedTime.LessThanFiveMins:
                return qsTr("< 5 minutes")
            default:
                return qsTr("> 5 minutes")
            }
        }
    }

    width: parent.width
    height: visible ? (!advancedOrCustomMode ? selectorButtons.height  : advancedGasSelector.height) + Style.current.halfPadding : 0


    Row {
        id: selectorButtons
        visible: !root.advancedOrCustomMode
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        spacing: 11

        ButtonGroup {
            buttons: gasPrioRepeater.children
        }

        Repeater {
            id: gasPrioRepeater
            model: root.estimatedGasFeesTime
            GasSelectorButton {
                objectName: "GasSelector_slowGasButton"
                property double totalFeesInFiat: parseFloat(root.getFiatValue(modelData.totalFeesInEth, "ETH", currentCurrency)) +
                                                 parseFloat(root.getFiatValue(modelData.totalTokenFees, root.selectedTokenSymbol, currentCurrency))
                primaryText: index === 0 ? qsTr("Slow") : index === 1 ? qsTr("Optimal"):  qsTr("Fast")
                timeText: index === selectedPriority ? d.getLabelForEstimatedTxTime(modelData.totalTime): qsTr("~ Unknown")
                totalGasEthValue: modelData.totalFeesInEth
                totalGasFiatValue: index === selectedPriority ? "%1 %2".arg(LocaleUtils.numberToLocaleString(totalFeesInFiat)).arg(root.currentCurrency.toUpperCase()): qsTr("...")
                checked: index === selectedPriority
                onCheckedChanged: {
                    if(checked) {
                        root.selectedPriority = index
                        root.selectedGasEthValue = totalGasEthValue
                        root.selectedGasFiatValue = totalGasFiatValue
                        root.selectedTimeEstimate = timeText
                    }
                }
            }
        }
    }

    Column {
        id: advancedGasSelector
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 10
        visible: root.advancedOrCustomMode

        spacing: Style.current.halfPadding

        StatusSwitchTabBar {
            id: tabBar
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.advancedOrCustomMode
            StatusSwitchTabButton {
                text: qsTr("Slow")
            }
            StatusSwitchTabButton {
                text: qsTr("Optimal")
            }
            StatusSwitchTabButton {
                text: qsTr("Fast")
            }

            currentIndex: GasSelector.Priority.OPTIMAL

            onCurrentIndexChanged:  {
                root.selectedPriority = currentIndex
                if(gasPrioRepeater.count === 3) {
                    root.selectedGasFiatValue =  gasPrioRepeater.itemAt(currentIndex).totalGasFiatValue
                    root.selectedGasEthValue =  gasPrioRepeater.itemAt(currentIndex).totalGasEthValue
                    root.selectedTimeEstimate =  gasPrioRepeater.itemAt(currentIndex).timeText
                }
            }
        }

        // Normal transaction
        Repeater {
            model: root.bestRoutes
            StatusListItem {
                id: listItem
                color: Theme.palette.statusListItem.backgroundColor
                width: parent.width
                asset.name: index == 0 ? "tiny/gas" : ""
                title: qsTr("%1 transaction fee").arg(modelData.fromNetwork.chainName)
                subTitle: "%1 eth".arg(LocaleUtils.numberToLocaleString(parseFloat(totalGasAmount)))
                property string totalGasAmount : {
                    let maxFees = (tabBar.currentIndex === GasSelector.Priority.SLOW) ? modelData.gasFees.maxFeePerGasL :
                                                                                        (tabBar.currentIndex === GasSelector.Priority.OPTIMAL) ?
                                                                                            modelData.gasFees.maxFeePerGasM : modelData.gasFees.maxFeePerGasH
                    let gasPrice = modelData.gasFees.eip1559Enabled ? maxFees : modelData.gasFees.gasPrice
                    return root.getGasEthValue(gasPrice , modelData.gasAmount)
                }
                statusListItemSubTitle.width: listItem.width/2 - Style.current.smallPadding
                statusListItemSubTitle.elide: Text.ElideMiddle
                statusListItemSubTitle.wrapMode: Text.NoWrap
                components: [
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text: "%1%2".arg(currentCurrencySymbol).arg(LocaleUtils.numberToLocaleString(parseFloat(root.getFiatValue(totalGasAmount, "ETH", root.currentCurrency))))
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                        width: listItem.width/2 - Style.current.padding
                        elide: Text.ElideRight
                    }
                ]
            }
        }

        // Bridge
        Repeater {
            model: root.bestRoutes
            StatusListItem {
                id: listItem2
                color: Theme.palette.statusListItem.backgroundColor
                width: parent.width
                asset.name: index == 0 ? "tiny/bridge" : ""
                title: qsTr("%1 -> %2 bridge").arg(modelData.fromNetwork.chainName).arg(modelData.toNetwork.chainName)
                subTitle: "%1 %2".arg(LocaleUtils.numberToLocaleString(modelData.tokenFees)).arg(root.selectedTokenSymbol)
                visible: modelData.bridgeName !== "Simple"
                statusListItemSubTitle.width: 100//parent.width - Style.current.smallPadding
                statusListItemSubTitle.elide: Text.ElideMiddle
                components: [
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text: "%1%2".arg(currentCurrencySymbol).arg(LocaleUtils.numberToLocaleString(parseFloat(root.getFiatValue(modelData.tokenFees, root.selectedTokenSymbol, root.currentCurrency))))
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                        width: listItem2.width/2 - Style.current.padding
                        elide: Text.ElideRight
                    }
                ]
            }
        }
    }
}
