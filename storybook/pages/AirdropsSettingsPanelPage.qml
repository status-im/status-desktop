import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.controls 1.0
import utils 1.0

import SortFilterProxyModel 0.2

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    Logs { id: logs }

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "compressed_" + publicKey
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({ ensVerified: true })
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Button {
        text: "Back"
        onClicked: loader.item.navigateBack()
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        Loader {
            id: loader

            anchors.fill: parent
            active: globalUtilsReady && mainModuleReady

            sourceComponent: AirdropsSettingsPanel {
                id: airdropsSettingsPanel

                anchors.fill: parent
                anchors.topMargin: 50
                assetsModel: AssetsModel {}
                collectiblesModel: ListModel {}

                CollectiblesModel {
                    id: collectiblesModel
                }

                SortFilterProxyModel {
                    id: collectiblesModelWithSupply

                    sourceModel: collectiblesModel

                    proxyRoles: [
                        ExpressionRole {
                            name: "supply"
                            expression: ((model.index + 1) * 115).toString()
                        },
                        ExpressionRole {
                            name: "infiniteSupply"
                            expression: !(model.index % 4)
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

                    filters: ValueFilter {
                        roleName: "category"
                        value: TokenCategories.Category.Community
                    }

                    Component.onCompleted: {
                        Qt.callLater(() => airdropsSettingsPanel.collectiblesModel = this)
                    }
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
                            expression: ((model.index + 1) * 258).toString()
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


                    Component.onCompleted: {
                        Qt.callLater(() => airdropsSettingsPanel.assetsModel = this)
                    }
                }

                membersModel: UsersModel {}

                communityDetails: QtObject {
                    readonly property string name: "Socks"
                    readonly property string id: "SOCKS"
                    readonly property string image: ModelsData.icons.socks
                    readonly property string color: "red"
                    readonly property bool owner: true
                }

                onAirdropClicked: logs.logEvent("AirdropsSettingsPanel::onAirdropClicked")
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText
    }
}
