import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../controls"

Rectangle {
    id: root

    property alias selectedPriority: gasSelector.selectedPriority
    property alias selectedGasEthValue: gasSelector.selectedGasEthValue
    property alias selectedGasFiatValue: gasSelector.selectedGasFiatValue
    property alias selectedTimeEstimate: gasSelector.selectedTimeEstimate
    property alias estimatedGasFeesTime: gasSelector.estimatedGasFeesTime
    property alias isValid: gasValidator.isValid

    property bool isLoading: false
    property var bestRoutes
    property var store
    property var selectedTokenSymbol
    property bool advancedOrCustomMode
    signal priorityChanged()

    radius: 13
    color: Theme.palette.indirectColor1
    height: text.height + gasSelector.height + gasValidator.height + Style.current.xlPadding

    RowLayout {
        id: feesLayout
        spacing: 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Style.current.padding

        StatusRoundIcon {
            id: feesIcon
            Layout.alignment: Qt.AlignTop
            radius: 8
            asset.name: "fees"
        }
        Column {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredWidth: root.width - feesIcon.width - Style.current.xlPadding
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
                    anchors.rightMargin: Style.current.padding
                    id: totalFeesAdvanced
                    text: root.isLoading ? "..." : gasSelector.selectedGasFiatValue
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    visible: root.advancedOrCustomMode && root.bestRoutes.length > 0
                }
            }
            GasSelector {
                id: gasSelector
                width: parent.width
                getGasEthValue: root.store.getGasEthValue
                getFiatValue: root.store.getFiatValue
                currentCurrency: root.store.currencyStore.currentCurrency
                currentCurrencySymbol: root.store.currencyStore.currentCurrencySymbol
                visible: gasValidator.isValid && !root.isLoading
                advancedOrCustomMode: root.advancedOrCustomMode
                bestRoutes: root.bestRoutes
                selectedTokenSymbol: root.selectedTokenSymbol
                onSelectedPriorityChanged: root.priorityChanged()
            }
            GasValidator {
                id: gasValidator
                width: parent.width
                isLoading: root.isLoading
                isValid: root.bestRoutes ? root.bestRoutes.length > 0 : true
            }
        }
    }
}
