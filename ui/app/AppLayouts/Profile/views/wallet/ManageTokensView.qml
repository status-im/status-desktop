import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Models 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0
import shared.stores 1.0 as SharedStores
import utils 1.0

import AppLayouts.Profile.panels 1.0
import AppLayouts.Wallet.panels 1.0

ColumnLayout {
    id: root

    required property var sourcesOfTokensModel // Expected roles: key, name, updatedAt, source, version, tokensCount, image
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl

    required property var baseWalletAssetsModel
    required property var baseWalletCollectiblesModel

    property alias currentIndex: tabBar.currentIndex

    readonly property bool dirty: {
        if (!loader.item)
            return false
        if (tabBar.currentIndex > d.hiddenTabIndex)
            return false
        // FIXME take advanced settings into account here too (#13178)
        if (tabBar.currentIndex === d.collectiblesTabIndex && baseWalletCollectiblesModel.isFetching)
            return false
        return loader.item && loader.item.dirty
    }

    function saveChanges() {
        if (tabBar.currentIndex > d.hiddenTabIndex)
            return
        // FIXME save advanced settings (#13178)
        loader.item.saveSettings()
    }

    function resetChanges() {
        if (tabBar.currentIndex > d.hiddenTabIndex)
            return
        loader.item.revert()
    }

    QtObject {
        id: d

        readonly property int assetsTabIndex: 0
        readonly property int collectiblesTabIndex: 1
        readonly property int hiddenTabIndex: 2
        readonly property int advancedTabIndex: 3

        // assets
        readonly property var assetsController: ManageTokensController {
            sourceModel: root.baseWalletAssetsModel
            settingsKey: "WalletAssets"
            onTokenHidden: (symbol, name) => Global.displayToastMessage(
                               qsTr("%1 (%2) was successfully hidden").arg(name).arg(symbol), "", "checkmark-circle",
                               false, Constants.ephemeralNotificationType.success, "")
            onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                             qsTr("%1 community assets successfully hidden").arg(communityName), "", "checkmark-circle",
                                             false, Constants.ephemeralNotificationType.success, "")
            onTokenShown: (symbol, name) => Global.displayToastMessage(qsTr("%1 is now visible").arg(name), "", "checkmark-circle",
                                                                       false, Constants.ephemeralNotificationType.success, "")
            onCommunityTokenGroupShown: (communityName) => Global.displayToastMessage(
                                            qsTr("%1 community assets are now visible").arg(communityName), "", "checkmark-circle",
                                            false, Constants.ephemeralNotificationType.success, "")
        }

        // collectibles
        readonly property var renamedCollectiblesModel: RolesRenamingModel {
            sourceModel: root.baseWalletCollectiblesModel
            mapping: [
                RoleRename {
                    from: "uid"
                    to: "symbol"
                }
            ]
        }

        readonly property var collectiblesController: ManageTokensController {
            sourceModel: d.renamedCollectiblesModel
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

        function checkLoadMoreCollectibles() {
            if (tabBar.currentIndex !== collectiblesTabIndex)
                return
            // If there is no more items to load or we're already fetching, return
            if (!root.baseWalletCollectiblesModel.hasMore || root.baseWalletCollectiblesModel.isFetching)
                return
            root.baseWalletCollectiblesModel.loadMore()
        }
    }

    Connections {
        target: root.baseWalletCollectiblesModel
        function onHasMoreChanged() {
            d.checkLoadMoreCollectibles()
        }
        function onIsFetchingChanged() {
            d.checkLoadMoreCollectibles()
        }
    }

    StatusTabBar {
        id: tabBar

        Layout.fillWidth: true
        Layout.topMargin: 5

        StatusTabButton {
            leftPadding: 0
            width: implicitWidth
            text: qsTr("Assets")
        }
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Collectibles")
        }
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Hidden")
        }
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Advanced")
        }
    }

    // NB: we want to discard any pending unsaved changes when switching tabs or navigating away
    Loader {
        id: loader
        Layout.fillWidth: true
        Layout.fillHeight: true
        active: visible

        sourceComponent: {
            switch (tabBar.currentIndex) {
            case d.assetsTabIndex:
                return tokensPanel
            case d.collectiblesTabIndex:
                return collectiblesPanel
            case d.hiddenTabIndex:
                return hiddenPanel
            case d.advancedTabIndex:
                return advancedTab
            }
        }
    }

    Component {
        id: tokensPanel
        ManageAssetsPanel {
            controller: d.assetsController
        }
    }

    Component {
        id: collectiblesPanel
        ManageCollectiblesPanel {
            controller: d.collectiblesController
            Component.onCompleted: d.checkLoadMoreCollectibles()
        }
    }

    Component {
        id: hiddenPanel
        ManageHiddenPanel {
            assetsController: d.assetsController
            collectiblesController: d.collectiblesController
        }
    }

    Component {
        id: advancedTab
        ColumnLayout {
            spacing: 0
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: 18
                Layout.bottomMargin: 18
                text: qsTr("Token lists")
                color: Theme.palette.baseColor1
            }
            SupportedTokenListsPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourcesOfTokensModel: root.sourcesOfTokensModel
                tokensListModel: root.tokensListModel
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: 40 + 18
                Layout.bottomMargin: 26
                text: qsTr("Asset settings")
                color: Theme.palette.baseColor1
            }
            StatusDialogDivider {
                Layout.fillWidth: true
            }
            StatusListItem {
                Layout.fillWidth: true
                title: qsTr("Show community assets when sending tokens")

                components: [
                    StatusSwitch {
                        id: showCommunityAssetsSwitch
                        checked: true // FIXME integrate with backend (#13178)
                        onCheckedChanged: {
                            // FIXME integrate with backend (#13178)
                        }
                    }
                ]
                onClicked: {
                    showCommunityAssetsSwitch.checked = !showCommunityAssetsSwitch.checked
                }
            }
            StatusDialogDivider {
                Layout.fillWidth: true
            }
            StatusListItem {
                Layout.fillWidth: true
                title: qsTr("Don’t display assets with balance lower than")

                components: [
                    CurrencyAmountInput {
                        enabled: displayThresholdSwitch.checked
                        currencySymbol: SharedStores.RootStore.currencyStore.currentCurrency
                        value: 0.10 // FIXME integrate with backend (#13178)
                    },
                    StatusSwitch {
                        id: displayThresholdSwitch
                        checked: false // FIXME integrate with backend (#13178)
                        onCheckedChanged: {
                            // FIXME integrate with backend (#13178)
                        }
                    }
                ]
                onClicked: {
                    displayThresholdSwitch.checked = !displayThresholdSwitch.checked
                }
            }
        }
    }
}
