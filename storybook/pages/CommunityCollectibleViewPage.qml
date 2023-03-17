import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views.communities 1.0

import Storybook 1.0
import Models 1.0

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            CommunityCollectibleView {
                id: view

                anchors.fill: parent
                anchors.margins: 50
                holdersModel: TokenHoldersModel {}
                artworkSource: ModelsData.icons.superRare
                preview: previewBox.checked
                deployState: mintingStateBox.checked ? 1 : 0
                name: nameText.text
                symbol: symbolText.text
                description: descriptionText.text
                supplyText: supplyText.text
                infiniteSupply: unlimitedSupplyChecker.checked
                transferable: transferibleChecker.checked
                selfDestruct: selfdestructChecker.checked
                chainId: 1
                chainName: "Ethereum Mainnet"
                chainIcon: ModelsData.networks.ethereum
                accountName: "helloworld"

                onMintCollectible: logs.logEvent("CommunityCollectibleView::mintCollectible: \n"
                                                 + "artworkSource: " + artworkSource + "\n"
                                                 + "name: " + name + "\n"
                                                 + "symbol: " + symbol + "\n"
                                                 + "description: " + description + "\n"
                                                 + "supply: " + supply + "\n"
                                                 + "infiniteSupply: " + infiniteSupply + "\n"
                                                 + "transferable: " + transferable + "\n"
                                                 + "selfDestruct: " + selfDestruct + "\n"
                                                 + "chainId: " + chainId)
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

        ColumnLayout {

            CheckBox {
                id: previewBox
                text: "Is preview view?"
                checked: true
            }

            CheckBox {
                id: mintingStateBox
                text: "Minting in progress"
                checked: true
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Artwork"
            }

            RadioButton {
                text: "Small"
                checked: true
                onCheckedChanged: view.artworkSource = ModelsData.icons.superRare
            }

            RadioButton {
                text: "Medium"
                onCheckedChanged: view.artworkSource = ModelsData.collectibles.kitty2Big
            }

            RadioButton {
                text: "Large"
                onCheckedChanged: view.artworkSource = ModelsData.banners.superRare
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Name"
            }

            TextField {
                id: nameText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Art work"
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Description"
            }

            TextField {
                id: descriptionText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Long art work description Long art work description Long art work description Long art work description Long art work description Long art work description Long art work description Long art work description Long art work description"
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Symbol"
            }

            TextField {
                id: symbolText
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "ABC"
            }

            CheckBox {
                id: unlimitedSupplyChecker
                Layout.topMargin: 10
                text: "Unlimited supply"
                checked: true
            }

            Label {
                visible: !unlimitedSupplyChecker.checked
                Layout.fillWidth: true
                text: "Supply"
            }

            TextField {
                id: supplyText
                visible: !unlimitedSupplyChecker.checked
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "123"
            }

            CheckBox {
                id: transferibleChecker
                Layout.topMargin: 10
                text: "Tranferible"
                checked: true
            }

            CheckBox {
                id: selfdestructChecker
                text: "Remote self-desctruct"
                checked: true
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Network"
            }

            RadioButton {
                id: eth
                text: "Ethereum Mainnet"
                checked: true
                onCheckedChanged:  {
                    view.chainName = text
                    view.chainIcon = ModelsData.networks.ethereum
                    view.chainId = 1
                }
            }

            RadioButton {
                id: opt
                text: "Optimism"
                onCheckedChanged:  {
                    view.chainName = text
                    view.chainIcon = ModelsData.networks.optimism
                    view.chainId = 2
                }
            }

            RadioButton {
                id: arb
                text: "Arbitrum"
                onCheckedChanged:  {
                    view.chainName = text
                    view.chainIcon = ModelsData.networks.arbitrum
                    view.chainId = 3
                }
            }
        }
    }
}
