import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views.communities 1.0

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

            CommunityTokenView {
                id: view

                anchors.fill: parent
                anchors.margins: 50
                artworkSource: ModelsData.icons.superRare
                preview: previewBox.checked
                isAssetView: isAssetBox.checked
                remotelyDestructState: remotelyDestructStateBox.checked ? 1 /*In progress*/ : 2 /*Completed*/
                burnState: burnDestructStateBox.checked ? 1 /*In progress*/ : 2 /*Completed*/
                name: nameText.text
                symbol: symbolText.text
                description: descriptionText.text
                supplyAmount: parseInt(supplyText.text)
                infiniteSupply: unlimitedSupplyChecker.checked
                assetDecimals: parseInt(decimalText.text)
                remainingTokens: parseInt(remainingText.text)
                transferable: transferibleChecker.checked
                selfDestruct: selfdestructChecker.checked
                chainId: 1
                chainName: "Ethereum Mainnet"
                chainIcon: ModelsData.networks.ethereum
                accountName: "helloworld"

                onMintCollectible: logs.logEvent("CommunityTokenView::onMintCollectible: \n"
                                                 + "artworkSource: " + artworkSource + "\n"
                                                 + "name: " + name + "\n"
                                                 + "symbol: " + symbol + "\n"
                                                 + "description: " + description + "\n"
                                                 + "supply: " + supply + "\n"
                                                 + "infiniteSupply: " + infiniteSupply + "\n"
                                                 + "transferable: " + transferable + "\n"
                                                 + "selfDestruct: " + selfDestruct + "\n"
                                                 + "chainId: " + chainId + "\n"
                                                 + "accountName: " + accountName)

                onMintAsset: logs.logEvent("CommunityTokenView::onMintAsset: \n"
                                           + "artworkSource: " + artworkSource + "\n"
                                           + "name: " + name + "\n"
                                           + "symbol: " + symbol + "\n"
                                           + "description: " + description + "\n"
                                           + "supply: " + supply + "\n"
                                           + "infiniteSupply: " + infiniteSupply + "\n"
                                           + "decimals: " + decimals + "\n"
                                           + "chainId: " + chainId + "\n"
                                           + "accountName: " + accountName)
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
                        onCheckedChanged: if(checked) view.deployState = Constants.BackendProcessState.InProgress
                    }

                    RadioButton {
                        id: mintingFailed
                        text: "Failed"
                        onCheckedChanged: if(checked) view.deployState = Constants.BackendProcessState.Failed
                    }

                    RadioButton {
                        id: mintingCompleted
                        text: "Completed"
                        checked: true
                        onCheckedChanged: if(checked) view.deployState = Constants.BackendProcessState.Completed
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
}
