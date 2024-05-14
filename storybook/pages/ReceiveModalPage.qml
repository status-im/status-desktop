import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import StatusQ.Core.Utils 0.1

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
                "preferredSharingChainIds": "10:42161:1:"
            }
            switchingAccounsEnabled: true
            changingPreferredChainsEnabled: true
            hasFloatingButtons: true
            qrImageSource: "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"
            getNetworkShortNames: function (chainIDsString) {
                let chainArray = chainIDsString.split(":")
                let chainNameString = ""
                for (let i =0; i<chainArray.length; i++) {
                    chainNameString += NetworksModel.getShortChainName(Number(chainArray[i])) + ":"
                }
                return chainNameString
            }

            property string networksNames: "oeth:arb1:eth:"

            store: QtObject {
                property var filteredFlatModel: SortFilterProxyModel {
                    sourceModel: NetworksModel.flatNetworks
                    filters: ValueFilter { roleName: "isTest"; value: false }
                }

                function getAllNetworksChainIds() {
                    let result = []
                    let chainIdsArray = ModelUtils.modelToFlatArray(filteredFlatModel, "chainId")
                    for(let i = 0; i< chainIdsArray.length; i++) {
                        result.push(chainIdsArray[i].toString())
                    }
                    return result
                }

                function processPreferredSharingNetworkToggle(preferredSharingNetworks, toggledNetwork) {
                    let prefChains = preferredSharingNetworks
                    if(prefChains.length === filteredFlatModel.count) {
                        prefChains = [toggledNetwork.chainId.toString()]
                    }
                    else if(!prefChains.includes(toggledNetwork.chainId.toString())) {
                        prefChains.push(toggledNetwork.chainId.toString())
                    }
                    else {
                        if(prefChains.length === 1) {
                            prefChains = getAllNetworksChainIds()
                        }
                        else {
                            for(var i = 0; i < prefChains.length;i++) {
                                if(prefChains[i] === toggledNetwork.chainId.toString()) {
                                    prefChains.splice(i, 1)
                                }
                            }
                        }
                    }
                    return prefChains
                }
            }
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
                        dialog.networksNames = "oeth:arb1:eth:arb1:solana:status:other:"
                    }
                }

                RadioButton {
                    text: "Super long address"
                    onCheckedChanged: {
                        dialog.networksNames = "oeth:arb1:eth:arb1:solana:status:other:something:hey:whatsapp:tele:viber:do:it:now:blackjack:some:black:number:check:it:out:heyeey:dosay:what:are:you:going:to:do:with:me:forever:young:michael:jackson:super:long:string:crasy:daisy:this:is:amazing:whatever:you:do:whenever:you:go:"
                    }
                }

                RadioButton {
                    checked: true
                    text: "Short address"
                    onCheckedChanged: {
                        dialog.networksNames = "oeth:arb1:eth:"
                    }
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20734-337595&mode=design&t=2O68lxNGG9g1b1tx-4
