import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import Storybook 1.0
import Models 1.0
import SortFilterProxyModel 0.2

import StatusQ 0.1

import utils 1.0
import shared.views 1.0

SplitView {
    id: root

    Logs { id: logs }

    readonly property string networksChainsCurrentlySelected: {
        let supportNwChains = ";"
        for (let i =0; i< NetworksModel.allNetworks.count; i++) {
            if (NetworksModel.allNetworks.get(i).isEnabled)
                supportNwChains +=  NetworksModel.allNetworks.get(i).chainId + ";"
        }
        return supportNwChains
    }

    readonly property string addressesSelected: {
        let supportedAddresses = ";"
        for (let i =0; i< accountsRepeater.count; i++) {
            if (accountsRepeater.itemAt(i).checked)
                supportedAddresses +=  accountsRepeater.itemAt(i).address + ";"
        }
        return supportedAddresses
    }


    readonly property var flatAccountsAssetsModel: FlatAccountsAssetsModel {}
    readonly property var sfpmflatAccountsAssetsModel: SortFilterProxyModel {
        sourceModel: flatAccountsAssetsModel
        filters: ExpressionFilter {
                expression: {
                    addressesSelected
                    networksChainsCurrentlySelected
                    return networksChainsCurrentlySelected.split(";").includes(model.chainId+"") &&
                            addressesSelected.split(";").includes(model.account)
                }
            }
    }

    readonly property var flatTokensModel: FlatTokensModel {}
    readonly property var renamedFlatTokensModel: RolesRenamingModel {
        sourceModel: flatTokensModel
        mapping: [
            RoleRename {
                from: "key"
                to: "tokenKey"
            },
            RoleRename {
                from: "chainId"
                // check naming here
                to: "flatChainId"
            }
        ]
    }

    readonly property var joinModel: LeftJoinModel {
        leftModel: sfpmflatAccountsAssetsModel
        rightModel: renamedFlatTokensModel

        joinRole: "tokenKey"
    }

    readonly property var tokensProxyModel: SortFilterProxyModel {
        sourceModel: joinModel
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        AssetsView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            assets: joinModel
            networkConnectionStore: null
            areAssetsLoading: loadingCheckbox.checked
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
            spacing: 12
            anchors.fill: parent

            CheckBox {
                id: loadingCheckbox
                checked: true
                text: "loading"
            }

            Text {
                text: "select supported network(s)"
            }
            ListView {
                id: networksList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: NetworksModel.allNetworks
                delegate: CheckBox {
                    width: ListView.view.width
                    text: chainName
                    checked: true
                    onToggled: {
                        isEnabled = checked
                    }
                }
            }

            Text {
                text: "select account(s)"
            }
            ColumnLayout {
                Layout.fillWidth: true
                Repeater {
                    id: accountsRepeater
                    model: WalletAccountsModel {}
                    delegate: CheckBox {
                        property string address: model.address
                        checked: true
                        width: ListView.view.width
                        text: name
                    }
                }
            }
        }
    }
}

// category: Wallet
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18057%3A239798&mode=design&t=Vnm5GS8EZFLpeRAY-1
