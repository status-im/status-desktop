import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Models 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import mainui 1.0
import utils 1.0

import AppLayouts.Wallet.views 1.0
import AppLayouts.Wallet.stores 1.0

import shared.views 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageCollectiblesModel {
        id: collectiblesModel
        includeRegularCollectibles: ctrlIncludeRegularCollectibles.checked
        includeCommunityCollectibles: ctrlIncludeCommunityCollectibles.checked
    }

    RolesRenamingModel {
        id: renamedModel
        sourceModel: collectiblesModel

        mapping: [
            RoleRename {
                from: "uid"
                to: "symbol"
            }
        ]
    }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: QtObject {}
        walletCollectiblesStore: CollectiblesStore {
            collectiblesController: collectiblesView.controller
        }
    }

    QtObject {
        id: d
        readonly property string networksChainsCurrentlySelected: {
            let supportNwChains = ":"
            for (let i =0; i< networksRepeater.count; i++) {
                if (networksRepeater.itemAt(i).checked && networksRepeater.itemAt(i).visible)
                    supportNwChains +=  networksRepeater.itemAt(i).chainID + ":"
            }
            return supportNwChains
        }

        readonly property string addressesSelected: {
            let supportedAddresses = ""
            for (let i =0; i< accountsRepeater.count; i++) {
                if (accountsRepeater.itemAt(i).checked && accountsRepeater.itemAt(i).visible)
                    supportedAddresses += accountsRepeater.itemAt(i).address + ":"
            }
            return supportedAddresses
        }
    }

    CollectiblesView {
        id: collectiblesView

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        controller: ManageTokensController {
            sourceModel: renamedModel
            settingsKey: "WalletCollectibles"
            onTokenHidden: (symbol, name) => Global.displayToastMessage(
                               qsTr("%1 was successfully hidden").arg(name), "", "checkmark-circle",
                               false, Constants.ephemeralNotificationType.success, "")
            onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                             qsTr("%1 community collectibles successfully hidden").arg(communityName), "", "checkmark-circle",
                                             false, Constants.ephemeralNotificationType.success, "")
            onTokenShown: (symbol, name) => Global.displayToastMessage(qsTr("%1 is now visible").arg(name), "", "checkmark-circle",
                                                                       false, Constants.ephemeralNotificationType.success, "")
            onCommunityTokenGroupShown: (communityName) => Global.displayToastMessage(
                                            qsTr("%1 community collectibles are now visible").arg(communityName), "", "checkmark-circle",
                                            false, Constants.ephemeralNotificationType.success, "")
        }
        networkFilters: d.networksChainsCurrentlySelected
        addressFilters: d.addressesSelected
        filterVisible: ctrlFilterVisible.checked
        onCollectibleClicked: logs.logEvent("onCollectibleClicked", ["chainId", "contractAddress", "tokenId", "uid"], arguments)
        onSendRequested: logs.logEvent("onSendRequested", ["symbol"], arguments)
        onReceiveRequested: logs.logEvent("onReceiveRequested", ["symbol"], arguments)
        onSwitchToCommunityRequested: logs.logEvent("onSwitchToCommunityRequested", ["communityId"], arguments)
        onManageTokensRequested: logs.logEvent("onManageTokensRequested")
        isUpdating: ctrlUpdatingCheckbox.checked
        isFetching: ctrlFetchingCheckbox.checked
        isError: ctrlErrorCheckbox.checked
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            spacing: 12
            anchors.fill: parent

            Switch {
                id: ctrlFilterVisible
                text: "Filter visible"
                checked: true
            }
            Switch {
                id: ctrlIncludeRegularCollectibles
                text: "Regular collectibles"
                checked: true
            }
            Switch {
                id: ctrlIncludeCommunityCollectibles
                text: "Community collectibles"
                checked: true
            }

            CheckBox {
                id: ctrlUpdatingCheckbox
                checked: false
                text: "isUpdating"
            }
            CheckBox {
                id: ctrlFetchingCheckbox
                checked: false
                text: "isFetching"
            }
            CheckBox {
                id: ctrlErrorCheckbox
                checked: false
                text: "isError"
            }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "select supported network(s)"
                }
                Repeater {
                    id: networksRepeater
                    model: NetworksModel.allNetworks
                    delegate: CheckBox {
                        property int chainID: chainId
                        width: parent.width
                        text: chainName
                        visible: isTest
                        checked: true
                        onToggled: {
                            isEnabled = checked
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "select account(s)"
                }
                Repeater {
                    id: accountsRepeater
                    model: WalletAccountsModel {}
                    delegate: CheckBox {
                        property string address: model.address
                        checked: true
                        visible: index<2
                        width: parent.width
                        text: name
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Views
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19558-95270&mode=design&t=ShZOuMRfiIIl2aR8-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19558-96427&mode=design&t=ShZOuMRfiIIl2aR8-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=19087%3A293357&mode=dev
