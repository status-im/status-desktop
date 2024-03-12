import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0
import AppLayouts.Wallet.popups 1.0

SplitView {
    orientation: Qt.Horizontal

    PopupBackground {
        id: popupBg

        property var popupIntance: null

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !dialog.visible

            onClicked: dialog.open()
        }

        ReceiveModal {
            id: dialog

            visible: true
            accounts: ListModel {
                ListElement {
                    position: 0
                    name: "My account"
                }
            }
            selectedAccount: {
                "name": "My account",
                "emoji": "",
                "address": "0x1234567890123456789012345678901234567890",
                "preferredSharingChainIds": "opt:eth:"
            }
            switchingAccounsEnabled: true
            changingPreferredChainsEnabled: true
            hasFloatingButtons: true
            qrImageSource: "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"
            getNetworkShortNames: function (chainIDsString) {
                return networksNames
            }

            property string networksNames: "opt:arb:eth:"

            store: NetworksModel
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Test extended footer"
                font.bold: true
            }

            Column {
                RadioButton {
                    text: "Medium length address"
                    onCheckedChanged: {
                        dialog.networksNames = "opt:arb:eth:arb:solana:status:other:"
                    }
                }

                RadioButton {
                    text: "Super long address"
                    onCheckedChanged: {
                        dialog.networksNames = "opt:arb:eth:arb:solana:status:other:something:hey:whatsapp:tele:viber:do:it:now:blackjack:some:black:number:check:it:out:heyeey:dosay:what:are:you:going:to:do:with:me:forever:young:michael:jackson:super:long:string:crasy:daisy:this:is:amazing:whatever:you:do:whenever:you:go:"
                    }
                }

                RadioButton {
                    checked: true
                    text: "Short address"
                    onCheckedChanged: {
                        dialog.networksNames = "opt:arb:eth:"
                    }
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20734-337595&mode=design&t=2O68lxNGG9g1b1tx-4
