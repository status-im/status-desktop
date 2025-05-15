import QtQuick 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.stores.send 1.0 as SharedSendStores

import "../controls"

ColumnLayout {
    id: root

    property SharedSendStores.TransactionStore store
    property var selectedRecipient
    property string ensAddressOrEmpty: ""
    property double amountToSend
    property int minSendCryptoDecimals: 0
    property int minReceiveCryptoDecimals: 0
    property var selectedAsset
    property bool isLoading: false
    property bool errorMode: networksLoader.item ? networksLoader.item.errorMode : false
    property var fnRawToDecimal: function(rawValue) {}
    property bool interactive: true
    property bool isBridgeTx: false
    property var toNetworksList
    property var fromNetworksList
    property int errorType: Constants.NoError

    signal reCalculateSuggestedRoute()

    RowLayout {
        Layout.fillWidth: true
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
                Layout.fillWidth: true
                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    text: qsTr("Networks")
                    wrapMode: Text.WordWrap
                }
                StatusButton {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: 22
                    verticalPadding: -1
                    checkable: true
                    size: StatusBaseButton.Size.Small
                    icon.name: checked ? "show" : "hide"
                    icon.height: 16
                    icon.width: 16
                    text: checked ? qsTr("Hide Unpreferred Networks"): qsTr("Show Unpreferred Networks")
                    visible: !isBridgeTx
                    checked: root.store.showUnPreferredChains
                    onClicked: {
                        root.store.toggleShowUnPreferredChains()
                        root.reCalculateSuggestedRoute()
                    }
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: isBridgeTx ? qsTr("Routes will be automatically calculated to give you the lowest cost.") :
                                   qsTr("The networks where the recipient will receive tokens. Amounts calculated automatically for the lowest cost.")
                wrapMode: Text.WordWrap
            }
            Loader {
                id: networksLoader
                Layout.fillWidth: true
                Layout.topMargin: Theme.padding
                visible: active
                sourceComponent: NetworkCardsComponent {
                    store: root.store
                    receiverIdentityText: root.ensAddressOrEmpty.length > 0 ?
                                              root.ensAddressOrEmpty : !!root.selectedRecipient ?
                                                  StatusQUtils.Utils.elideText(root.selectedRecipient.address, 6, 4).toUpperCase() :  ""
                    amountToSend: root.amountToSend
                    minSendCryptoDecimals: root.minSendCryptoDecimals
                    minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                    selectedAsset: root.selectedAsset
                    reCalculateSuggestedRoute: function() {
                        root.reCalculateSuggestedRoute()
                    }
                    toNetworksList: root.toNetworksList
                    fromNetworksList: root.fromNetworksList
                    fnRawToDecimal: root.fnRawToDecimal
                    interactive: root.interactive
                    errorType: root.errorType
                    isLoading: root.isLoading
                }
            }
        }
    }
}
