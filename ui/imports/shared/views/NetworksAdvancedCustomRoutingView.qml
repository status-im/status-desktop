import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

ColumnLayout {
    id: root

    property var store
    property var selectedAccount
    property double amountToSend: 0
    property double requiredGasInEth: 0
    property bool customMode: false
    property var selectedAsset
    property var bestRoutes
    property bool isLoading: false
    property bool errorMode: networksLoader.item ? networksLoader.item.errorMode : false
    property var weiToEth: function(wei) {}
    property bool interactive: true
    property bool isBridgeTx: false
    property bool showUnpreferredNetworks: preferredToggleButton.checked

    signal reCalculateSuggestedRoute()

    RowLayout {
        spacing: 10

        StatusRoundIcon {
            Layout.alignment: Qt.AlignTop
            radius: 8
            asset.name: "flash"
            asset.color: Theme.palette.directColor1
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            RowLayout {
                Layout.maximumWidth: 410
                StatusBaseText {
                    Layout.maximumWidth: 410
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    text: qsTr("Networks")
                    wrapMode: Text.WordWrap
                }
                StatusButton {
                    id: preferredToggleButton
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: 22
                    verticalPadding: -1
                    checkable: true
                    size: StatusBaseButton.Size.Small
                    icon.name: checked ? "show" : "hide"
                    icon.height: 16
                    icon.width: 16
                    text: checked ? qsTr("Hide Unpreferred Networks"): qsTr("Show Unpreferred Networks")
                    onToggled: if(!checked) store.addUnpreferredChainsToDisabledChains()
                    visible: !isBridgeTx
                }
            }
            StatusBaseText {
                Layout.maximumWidth: 410
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
                wrapMode: Text.WordWrap
            }
            BalanceExceeded {
                id: balanceExceeded
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.current.bigPadding
                transferPossible: root.store.disabledChainIdsToList.length > 0 || root.store.disabledChainIdsFromList.length > 0 ? true : root.bestRoutes ? root.bestRoutes.length > 0 : false
                amountToSend: root.amountToSend
                isLoading: root.isLoading
            }
            Loader {
                id: networksLoader
                Layout.topMargin: Style.current.padding
                active: !balanceExceeded.visible
                visible: active
                sourceComponent: NetworkCardsComponent {
                    store: root.store
                    selectedAccount: root.selectedAccount
                    allNetworks: root.store.allNetworks
                    amountToSend: root.amountToSend
                    customMode: root.customMode
                    requiredGasInEth: root.requiredGasInEth
                    selectedAsset: root.selectedAsset
                    reCalculateSuggestedRoute: function() {
                        root.reCalculateSuggestedRoute()
                    }
                    showPreferredChains: preferredToggleButton.checked
                    bestRoutes: root.bestRoutes
                    weiToEth: root.weiToEth
                    interactive: root.interactive
                }
            }
        }
    }
}
