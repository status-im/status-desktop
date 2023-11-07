import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.controls 1.0

import SortFilterProxyModel 0.2

import utils 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 50

        RowLayout {

            Label {
                text: "Open flow:"
            }

            Button {
                text: "Add"
                onClicked: {
                    holdingsDropdown.close()
                    holdingsDropdown.open()
                }
            }

            Button {
                text: "Update"
                onClicked: {
                    holdingsDropdown.close()
                    holdingsDropdown.setActiveTab(Constants.TokenType.ENS)
                    holdingsDropdown.openUpdateFlow()
                }
            }
        }

        HoldingsDropdown {
            id: holdingsDropdown

            parent: container
            anchors.centerIn: container

            allTokensMode: ctrlAllTokensMode.checked

            CollectiblesModel {
                id: collectiblesModel
            }

            SortFilterProxyModel {
                id: collectiblesModelWithSupply

                sourceModel: collectiblesModel

                proxyRoles: [
                    ExpressionRole {
                        name: "supply"
                        expression: (model.index === 1 ? 1 : (model.index + 1) * 115).toString()
                    },
                    ExpressionRole {
                        name: "multiplierIndex"
                        expression: 0
                    },
                    ExpressionRole {
                        name: "infiniteSupply"
                        expression: !((model.index + 1) % 4)
                    },
                    ExpressionRole {
                        name: "chainName"
                        expression: model.index ? "Optimism" : "Arbitrum"
                    },
                    ExpressionRole {

                        readonly property string icon1: "network/Network=Optimism"
                        readonly property string icon2: "network/Network=Arbitrum"

                        name: "chainIcon"
                        expression: model.index ? icon1 : icon2
                    }
                ]
            }

            AssetsModel {
                id: assetsModel
            }

            SortFilterProxyModel {
                id: assetsModelWithSupply

                sourceModel: assetsModel

                proxyRoles: [
                    ExpressionRole {
                        name: "supply"
                        expression: ((model.index + 1) * 584).toString()
                                    + "0".repeat(18)
                    },
                    ExpressionRole {
                        name: "multiplierIndex"
                        expression: 18
                    },
                    ExpressionRole {
                        name: "infiniteSupply"
                        expression: !(model.index % 4)
                    },
                    ExpressionRole {
                        name: "chainName"
                        expression: model.index ? "Ethereum Mainnet" : "Goerli"
                    },
                    ExpressionRole {

                        readonly property string icon1: "network/Network=Ethereum"
                        readonly property string icon2: "network/Network=Testnet"

                        name: "chainIcon"
                        expression: model.index ? icon1 : icon2
                    }
                ]

                filters: ValueFilter {
                    roleName: "category"
                    value: TokenCategories.Category.Community
                }
            }

            collectiblesModel: collectiblesModelWithSupply

            assetsModel: assetsModelWithSupply
            isENSTab: isEnsTabChecker.checked

            onOpened: contentItem.parent.parent = container
            Component.onCompleted: {
                holdingsDropdown.close()
                holdingsDropdown.open()
            }
        }
    }


    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        RowLayout {
            CheckBox {
                id: isEnsTabChecker
                text: "ENS tab visible"
                checked: true
            }

            CheckBox {
                id: isAirdropMode
                text: "Airdrop mode"
                checked: false
            }

            CheckBox {
                id: ctrlAllTokensMode
                text: "All tokens mode"
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22721%3A499660&t=F5yiYQV2YGPBdrJ8-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22827%3A501381&t=7gqqAFbdG5KrPOmn-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22733%3A502088&t=5QSRGGAhrksqBs8e-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22772%3A496580&t=7gqqAFbdG5KrPOmn-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22772%3A496653&t=7gqqAFbdG5KrPOmn-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22734%3A502737&t=7gqqAFbdG5KrPOmn-0
