import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"

ColumnLayout {
    id: root

    property var store
    property var selectedAccount
    property string ensAddressOrEmpty: ""
    property double amountToSend
    property int minSendCryptoDecimals: 0
    property int minReceiveCryptoDecimals: 0
    property bool customMode: false
    property var selectedAsset
    property bool isLoading: false
    property bool errorMode: networksLoader.item ? networksLoader.item.errorMode : false
    property var weiToEth: function(wei) {}
    property bool interactive: true
    property bool isBridgeTx: false
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
                text: qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
                wrapMode: Text.WordWrap
            }
            Loader {
                id: networksLoader
                Layout.fillWidth: true
                Layout.preferredHeight: item.height
                Layout.topMargin: Style.current.padding
                visible: active
                sourceComponent: NetworkCardsComponent {
                    store: root.store
                    receiverIdentityText: root.ensAddressOrEmpty.length > 0 ?
                                              root.ensAddressOrEmpty : !!root.selectedAccount ?
                                                  StatusQUtils.Utils.elideText(root.selectedAccount.address, 6, 4).toUpperCase() :  ""
                    amountToSend: root.amountToSend
                    minSendCryptoDecimals: root.minSendCryptoDecimals
                    minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                    customMode: root.customMode
                    selectedAsset: root.selectedAsset
                    reCalculateSuggestedRoute: function() {
                        root.reCalculateSuggestedRoute()
                    }
                    weiToEth: root.weiToEth
                    interactive: root.interactive
                    errorType: root.errorType
                    isLoading: root.isLoading
                }
            }
        }
    }
}
