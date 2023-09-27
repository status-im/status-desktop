import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.stores 1.0

import "../controls"

Rectangle {
    id: root

    property var gasFiatAmount
    property bool isLoading: false
    property var bestRoutes
    property var store
    property var currencyStore: store.currencyStore
    property string selectedTokenSymbol
    property int errorType: Constants.NoError

    radius: 13
    color: Theme.palette.indirectColor1
    height: columnLayout.height + feesIcon.height

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
            asset.color: Theme.palette.directColor1
        }
        Column {
            id: columnLayout
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredWidth: root.width - feesIcon.width - Style.current.xlPadding
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
                    anchors.rightMargin: Style.current.padding
                    id: totalFeesAdvanced
                    text: root.isLoading ? "..." : root.currencyStore.formatCurrencyAmount(root.gasFiatAmount, root.currencyStore.currentCurrency)
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    visible: !!root.bestRoutes && root.bestRoutes !== undefined && root.bestRoutes.count > 0
                }
            }
            GasSelector {
                id: gasSelector
                width: parent.width
                getGasEthValue: root.currencyStore.getGasEthValue
                getFiatValue: root.currencyStore.getFiatValue
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                currentCurrency: root.currencyStore.currentCurrency
                visible: root.errorType === Constants.NoError && !root.isLoading
                bestRoutes: root.bestRoutes
                selectedTokenSymbol: root.selectedTokenSymbol
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
