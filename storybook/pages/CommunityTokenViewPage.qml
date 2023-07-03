import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.helpers 1.0

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

            TokenObject {
                id: tokenObject

                type: tokenTypeButtonGroup.checkedButton.type

                artworkSource: artworkButtonGroup.checkedButton.source
                burnState: burnDestructStateBox.checked
                           ? Constants.ContractTransactionStatus.InProgress
                           : Constants.ContractTransactionStatus.Completed
                name: nameText.text
                deployState: mintingStateButtonGroup.checkedButton.mintingState
                symbol: symbolText.text
                description: descriptionText.text
                supply: parseInt(supplyText.text)
                infiniteSupply: unlimitedSupplyChecker.checked
                remainingTokens: parseInt(remainingText.text)
                chainId: networksGroup.checkedButton.chainId
                chainName: networksGroup.checkedButton.text
                chainIcon: networksGroup.checkedButton.chainIcon
                accountName: "helloworld"

                // collectible-specific properties
                remotelyDestructState: remotelyDestructStateBox.checked
                                       ? Constants.ContractTransactionStatus.InProgress
                                       : Constants.ContractTransactionStatus.Completed
                transferable: transferibleChecker.checked
                remotelyDestruct: selfdestructChecker.checked

                // asset-specific properties
                decimals: parseInt(decimalText.text)
            }

            CommunityTokenView {
                id: view

                anchors.fill: parent
                anchors.margins: 50
                preview: previewBox.checked

                token: tokenObject
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

        ScrollView {
            width: parent.width
            height: parent.height
            contentHeight: column.implicitHeight
            contentWidth: width

            ColumnLayout {
                id: column

                width: parent.width

                GroupBox {
                    Layout.fillWidth: true

                    title: "Token type"

                    ButtonGroup {
                        id: tokenTypeButtonGroup

                        buttons: tokenTypeColumn.children
                    }


                    ColumnLayout {
                        id: tokenTypeColumn

                        RadioButton {
                            id: isAssetRadioButton

                            readonly property int type:
                                Constants.TokenType.ERC20

                            text: "Asset"
                        }

                        RadioButton {
                            readonly property int type:
                                Constants.TokenType.ERC721

                            checked: true
                            text: "Collectible"
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    CheckBox {
                        id: previewBox
                        text: "Preview"
                        checked: true
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    title: "Minting state"

                    ButtonGroup {
                        id: mintingStateButtonGroup

                        buttons: mintingStateColumn.children
                    }

                    ColumnLayout {
                        id: mintingStateColumn

                        RadioButton {
                            readonly property int mintingState:
                                Constants.ContractTransactionStatus.InProgress

                            text: "In progress"
                        }

                        RadioButton {
                            readonly property int mintingState:
                                Constants.ContractTransactionStatus.Failed

                            text: "Failed"
                        }

                        RadioButton {
                            readonly property int mintingState:
                                Constants.ContractTransactionStatus.Completed

                            text: "Completed"
                            checked: true
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        CheckBox {
                            id: remotelyDestructStateBox

                            visible: !isAssetRadioButton.checked
                            text: "Remotely destruct in progress"
                            checked: false
                        }

                        CheckBox {
                            id: burnDestructStateBox

                            text: "Burn in progress"
                            checked: false
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    title: "Artwork"

                    ButtonGroup {
                        id: artworkButtonGroup

                        buttons: artworkColumn.children
                    }

                    ColumnLayout {
                        id: artworkColumn

                        RadioButton {
                            readonly property string source:
                                ModelsData.icons.superRare

                            text: "Small"
                            checked: true
                        }

                        RadioButton {
                            readonly property string source:
                                ModelsData.collectibles.kitty2Big

                            text: "Medium"
                        }

                        RadioButton {
                            readonly property string source:
                                ModelsData.banners.superRare

                            text: "Large"
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        Label {
                            text: "Name"
                        }

                        TextField {
                            id: nameText

                            Layout.fillWidth: true

                            text: "Art work"
                        }

                        Label {
                            text: "Description"
                        }

                        TextField {
                            id: descriptionText

                            Layout.fillWidth: true

                            text: ModelsData.descriptions.medium
                        }

                        Label {
                            text: "Symbol"
                        }

                        TextField {
                            id: symbolText

                            Layout.fillWidth: true

                            text: "ABC"
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {

                        CheckBox {
                            id: unlimitedSupplyChecker

                            text: "Unlimited supply"
                            checked: true
                        }

                        Label {
                            visible: !unlimitedSupplyChecker.checked
                            text: "Supply"
                        }

                        TextField {
                            id: supplyText

                            visible: !unlimitedSupplyChecker.checked
                            text: "123"
                        }

                        TextField {
                            id: remainingText

                            visible: !unlimitedSupplyChecker.checked
                            text: "123"
                        }

                        Label {
                            visible: isAssetRadioButton.checked
                            text: "Decimal"
                        }

                        TextField {
                            id: decimalText

                            visible: isAssetRadioButton.checked
                            text: "2"
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    visible: !isAssetRadioButton.checked

                    ColumnLayout {
                        CheckBox {
                            id: transferibleChecker

                            text: "Tranferible"
                            checked: true
                        }

                        CheckBox {
                            id: selfdestructChecker

                            text: "Remote self-desctruct"
                            checked: true
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true

                    title: "Network"

                    ButtonGroup {
                        id: networksGroup

                        buttons: networksColumn.children
                    }

                    ColumnLayout {
                        id: networksColumn

                        RadioButton {
                            text: "Ethereum Mainnet"
                            checked: true

                            readonly property string chainIcon:
                                ModelsData.networks.ethereum
                            readonly property int chainId: 1
                        }

                        RadioButton {
                            text: "Optimism"

                            readonly property string chainIcon:
                                ModelsData.networks.optimism
                            readonly property int chainId: 2
                        }

                        RadioButton {
                            text: "Arbitrum"

                            readonly property string chainIcon:
                                ModelsData.networks.arbitrum
                            readonly property int chainId: 3
                        }
                    }
                }

                Component.onCompleted: spacing *= 2
            }
        }
    }
}
