import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import AppLayouts.Communities.popups
import AppLayouts.Communities.helpers
import AppLayouts.Communities.stores as CommunitiesStores

import utils

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            FirstTokenReceivedPopup {
                id: dialog

                anchors.centerIn: parent
                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false

                communityId: "123"
                communityName: communityNameText.text
                communityLogo: ModelsData.collectibles.doodles
                communitiesStore: CommunitiesStores.CommunitiesStore {
                    function navigateToCommunity(id) {
                        logs.logEvent("FirstTokenReceivedPopup::onNavigateToCommunity: " + id)
                    }
                }

                tokenSymbol: tokenSymbolText.text
                tokenName: tokenNameText.text
                tokenAmount: tokenAmountText.text
                tokenType: Constants.TokenType.ERC20
                tokenImage: ModelsData.assets.eth

                onHideClicked: logs.logEvent("FirstTokenReceivedPopup::onHideClicked")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Community Name"
                font.bold: true
            }

            TextInput {
                id: communityNameText

                text: "Doodles"

            }

            Label {
                text: "Community Logo"
                font.bold: true
            }

            Column {

                RadioButton {
                    id: doodleLogo

                    text: "Doodle"
                    checked: true

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.doodles
                }

                RadioButton {
                    id: manaLogo

                    text: "Mana"

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.mana
                }

                RadioButton {
                    id: superRareLogo

                    text: "Status"

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.custom
                }
            }

            Label {
                text: "Token amount"
                font.bold: true
            }

            TextInput {
                id: tokenAmountText

                text: "1"
            }

            Label {
                text: "Token name"
                font.bold: true
            }

            TextInput {
                id: tokenNameText

                text: "DoodleCoin"
            }

            Label {
                text: "Token symbol"
                font.bold: true
            }

            TextInput {
                id: tokenSymbolText

                text: "DOO"
            }

            Label {
                text: "Token Type"
                font.bold: true
            }

            Column {

                RadioButton {
                    id: assetType

                    text: "Asset"
                    checked: true

                    onCheckedChanged: dialog.tokenType = Constants.TokenType.ERC20
                }

                RadioButton {
                    id: collectibleType

                    text: "Collectible"

                    onCheckedChanged: dialog.tokenType = Constants.TokenType.ERC721
                }
            }

            Label {
                text: "Token Image"
                font.bold: true
            }

            Column {

                visible: assetType.checked

                onVisibleChanged: {

                    if(visible) {
                        eth.checked = true
                        dialog.tokenImage = ModelsData.assets.eth
                    }
                }
                RadioButton {
                    id: eth

                    text: "Eth"
                    checked: true

                    onCheckedChanged: dialog.tokenImage = ModelsData.assets.eth
                }

                RadioButton {
                    text: "SuperRare"

                    onCheckedChanged: dialog.tokenImage = ModelsData.banners.superRare
                }

                RadioButton {
                    text: "SNT"

                    onCheckedChanged: dialog.tokenImage = ModelsData.assets.snt
                }
            }

            Column {

                visible: collectibleType.checked

                onVisibleChanged: {
                    if(visible) {
                        superrare.checked = true
                        dialog.tokenImage = ModelsData.banners.superRare
                    }
                }
                RadioButton {
                    id: superrare

                    text: "SuperRare"
                    checked: true

                    onCheckedChanged: dialog.tokenImage = ModelsData.banners.superRare
                }

                RadioButton {
                    text: "Coinbase"

                    onCheckedChanged: dialog.tokenImage = ModelsData.banners.coinbase
                }

                RadioButton {
                    text: "Dragonereum"

                    onCheckedChanged: dialog.tokenImage = ModelsData.banners.dragonereum
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18700%3A276658&mode=design&t=QzoyErtcBX8A54G7-1
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20765%3A244128&mode=design&t=X279c9Ix6QKMKWjM-1
