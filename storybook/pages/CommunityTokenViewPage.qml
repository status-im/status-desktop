import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.helpers 1.0

import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0

import utils 1.0

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            CollectibleObject {
                id: collectibleObj

                artworkSource: ModelsData.icons.superRare
                remotelyDestructState: remotelyDestructStateBox.checked ? 1 /*In progress*/ : 2 /*Completed*/
                burnState: burnDestructStateBox.checked ? 1 /*In progress*/ : 2 /*Completed*/
                name: nameText.text
                symbol: symbolText.text
                description: descriptionText.text
                supply: parseInt(supplyText.text)
                infiniteSupply: unlimitedSupplyChecker.checked
                remainingTokens: parseInt(remainingText.text)
                transferable: transferibleChecker.checked
                remotelyDestruct: selfdestructChecker.checked
                chainId: 1
                chainName: "Ethereum Mainnet"
                chainIcon: ModelsData.networks.ethereum
                accountName: "helloworld"
            }

            AssetObject {
                id: assetObj

                artworkSource: ModelsData.icons.superRare
                burnState: burnDestructStateBox.checked ? 1 /*In progress*/ : 2 /*Completed*/
                name: nameText.text
                symbol: symbolText.text
                description: descriptionText.text
                supply: parseInt(supplyText.text)
                infiniteSupply: unlimitedSupplyChecker.checked
                decimals: parseInt(decimalText.text)
                remainingTokens: parseInt(remainingText.text)
                chainId: 1
                chainName: "Ethereum Mainnet"
                chainIcon: ModelsData.networks.ethereum
                accountName: "helloworld"
            }

            CommunityTokenView {
                id: view

                anchors.fill: parent
                anchors.margins: 50
                preview: previewBox.checked
                isAssetView: isAssetBox.checked
                collectible: collectibleObj
                asset: assetObj
                tokenOwnersModel: TokenHoldersModel {}
                
                onMintClicked: logs.logEvent("CommunityTokenView::onMintClicked")
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

        StatusScrollView {
            width: parent.width
            height: parent.height
            contentHeight: _column.implicitHeight
            contentWidth: _column.implicitWidth

            ColumnLayout {
                id: _column

                CheckBox {
                    id: previewBox
                    text: "Is preview view?"
                    checked: true
                }

                CheckBox {
                    id: isAssetBox
                    text: "Is Assets View?"
                    checked: false
                }

                ColumnLayout {
                    Label {
                        text: "Minting state:"
                    }

                    RadioButton {
                        id: mintingInProgress
                        text: "In progress"
                        onCheckedChanged: {
                            if(view.isAssetView) assetObj.deployState = Constants.ContractTransactionStatus.InProgress
                            else collectibleObj.deployState = Constants.ContractTransactionStatus.InProgress
                        }
                    }

                    RadioButton {
                        id: mintingFailed
                        text: "Failed"
                        onCheckedChanged: {
                            if(view.isAssetView) assetObj.deployState = Constants.ContractTransactionStatus.Failed
                            else collectibleObj.deployState = Constants.ContractTransactionStatus.Failed
                        }
                    }

                    RadioButton {
                        id: mintingCompleted
                        text: "Completed"
                        checked: true
                        onCheckedChanged: {
                            if(view.isAssetView) assetObj.deployState = Constants.ContractTransactionStatus.Completed
                            else collectibleObj.deployState = Constants.ContractTransactionStatus.Completed
                        }
                    }
                }

                CheckBox {
                    id: remotelyDestructStateBox
                    visible: !isAssetBox.checked
                    text: "Remotely destruct in progress"
                    checked: false
                }

                CheckBox {
                    id: burnDestructStateBox
                    text: "Burn in progress"
                    checked: false
                }

                Label {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    text: "Artwork"
                }

                RadioButton {
                    text: "Small"
                    checked: true
                    onCheckedChanged: {
                        if(view.isAssetView) assetObj.artworkSource = ModelsData.icons.superRare
                        else collectibleObj.artworkSource = ModelsData.icons.superRare
                    }
                }

                RadioButton {
                    text: "Medium"
                    onCheckedChanged: {
                        if(view.isAssetView) assetObj.artworkSource = ModelsData.collectibles.kitty2Big
                        else collectibleObj.artworkSource = ModelsData.collectibles.kitty2Big
                    }
                }

                RadioButton {
                    text: "Large"
                    onCheckedChanged: {
                        if(view.isAssetView) assetObj.artworkSource = ModelsData.banners.superRare
                        else collectibleObj.artworkSource = ModelsData.banners.superRare
                    }
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

                TextField {
                    id: remainingText
                    visible: !unlimitedSupplyChecker.checked
                    background: Rectangle { border.color: 'lightgrey' }
                    Layout.preferredWidth: 200
                    text: "123"
                }

                Label {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    visible: isAssetBox.checked
                    text: "Decimal"
                }

                TextField {
                    id: decimalText
                    Layout.preferredWidth: 200
                    background: Rectangle { border.color: 'lightgrey' }
                    visible: isAssetBox.checked
                    text: "2"
                }

                CheckBox {
                    id: transferibleChecker
                    Layout.topMargin: 10
                    visible: !isAssetBox.checked
                    text: "Tranferible"
                    checked: true
                }

                CheckBox {
                    id: selfdestructChecker
                    visible: !isAssetBox.checked
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
                        if(view.isAssetView) {
                            assetObj.chainName = text
                            assetObj.chainIcon = ModelsData.networks.ethereum
                            assetObj.chainId = 1
                        } else {
                            collectibleObj.chainName = text
                            collectibleObj.chainIcon = ModelsData.networks.ethereum
                            collectibleObj.chainId = 1
                        }
                    }
                }

                RadioButton {
                    id: opt
                    text: "Optimism"
                    onCheckedChanged:  {
                        if(view.isAssetView) {
                            assetObj.chainName = text
                            assetObj.chainIcon = ModelsData.networks.optimism
                            assetObj.chainId = 2
                        } else {
                            collectibleObj.chainName = text
                            collectibleObj.chainIcon = ModelsData.networks.optimism
                            collectibleObj.chainId = 2
                        }
                    }
                }

                RadioButton {
                    id: arb
                    text: "Arbitrum"
                    onCheckedChanged:  {
                        if(view.isAssetView) {
                            assetObj.chainName = text
                            assetObj.chainIcon = ModelsData.networks.arbitrum
                            assetObj.chainId = 3
                        } else {
                            collectibleObj.chainName = text
                            collectibleObj.chainIcon = ModelsData.networks.arbitrum
                            collectibleObj.chainId = 3
                        }
                    }
                }
            }
        }
    }
}
