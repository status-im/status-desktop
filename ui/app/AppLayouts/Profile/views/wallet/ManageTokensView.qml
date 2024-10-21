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
import AppLayouts.Wallet.stores 1.0


Item {
    id: root

    required property TokensStore tokensStore

    required property double tokenListUpdatedAt
    required property var assetsController
    required property var collectiblesController

    required property var sourcesOfTokensModel // Expected roles: key, name, updatedAt, source, version, tokensCount, image
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl

    required property var baseWalletAssetsModel
    required property var baseWalletCollectiblesModel

    property string currencySymbol: "USD"
    property var getCurrencyAmount: function (balance, symbol) {}
    property var getCurrentCurrencyAmount: function(balance){}

    property alias currentIndex: tabBar.currentIndex

    readonly property bool dirty: !!loader.item && loader.item.dirty
    readonly property bool advancedTabVisible: tabBar.currentIndex === d.advancedTabIndex

    function saveChanges(update) {
        loader.item.saveSettings(update)
    }

    function resetChanges() {
        loader.item.resetChanges()
    }

    readonly property bool assetsPanelVisible: tabBar.currentIndex === d.assetsTabIndex
    readonly property bool collectiblesPanelVisible: tabBar.currentIndex === d.collectiblesTabIndex

    QtObject {
        id: d

        readonly property int assetsTabIndex: 0
        readonly property int collectiblesTabIndex: 1
        readonly property int hiddenTabIndex: 2
        readonly property int advancedTabIndex: 3
    }

    ColumnLayout {
        anchors.fill: parent

        StatusTabBar {
            id: tabBar

            Layout.fillWidth: true
            Layout.topMargin: 5

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                objectName: "assetsButton"
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
                    return assetsPanel
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
            id: assetsPanel
            ManageAssetsPanel {
                getCurrencyAmount: function (balance, symbol) {
                    return root.getCurrencyAmount(balance, symbol)
                }
                getCurrentCurrencyAmount: function (balance) {
                    return root.getCurrentCurrencyAmount(balance)
                }

                controller: root.assetsController
            }
        }

        Component {
            id: collectiblesPanel
            ManageCollectiblesPanel {
                controller: root.collectiblesController
            }
        }

        Component {
            id: hiddenPanel
            ManageHiddenPanel {
                getCurrencyAmount: function (balance, symbol) {
                    return root.getCurrencyAmount(balance, symbol)
                }
                getCurrentCurrencyAmount: function (balance) {
                    return root.getCurrentCurrencyAmount(balance)
                }
                assetsController: root.assetsController
                collectiblesController: root.collectiblesController
            }
        }

        Component {
            id: advancedTab
            ColumnLayout {
                id: advancedSettings

                function saveSettings() {
                    if (showCommunityAssetsSwitch.checked !== root.tokensStore.showCommunityAssetsInSend)
                        root.tokensStore.toggleShowCommunityAssetsInSend()
                    if (displayThresholdSwitch.checked !== root.tokensStore.displayAssetsBelowBalance)
                        root.tokensStore.toggleDisplayAssetsBelowBalance()
                    const rawAmount = currencyAmount.value * Math.pow(10, thresholdCurrency.displayDecimals)
                    if (rawAmount !== thresholdCurrency.amount) {
                        root.tokensStore.setDisplayAssetsBelowBalanceThreshold(rawAmount)
                    }
                    dirty = false
                }

                function resetChanges() {
                    showCommunityAssetsSwitch.checked = root.tokensStore.showCommunityAssetsInSend
                    displayThresholdSwitch.checked = root.tokensStore.displayAssetsBelowBalance
                    currencyAmount.value = getDisplayThresholdAmount()
                    dirty = false
                }

                function getDisplayThresholdAmount() {
                    return thresholdCurrency.amount / Math.pow(10, thresholdCurrency.displayDecimals)
                }

                property bool dirty: false

                readonly property var thresholdCurrency: root.tokensStore.getDisplayAssetsBelowBalanceThresholdCurrency()

                spacing: 8
                StatusListItem {
                    // Temporarily disabled, refer to https://github.com/status-im/status-desktop/issues/15955 for details.
                    visible: false

                    Layout.fillWidth: true
                    title: qsTr("Show community assets when sending tokens")

                    components: [
                        StatusSwitch {
                            id: showCommunityAssetsSwitch
                            checked: root.tokensStore.showCommunityAssetsInSend
                            onCheckedChanged: {
                                if (!advancedSettings.dirty && checked === root.tokensStore.showCommunityAssetsInSend) {
                                    // Skipping initial value
                                    return
                                }
                                advancedSettings.dirty = true
                            }
                        }
                    ]
                    onClicked: {
                        showCommunityAssetsSwitch.checked = !showCommunityAssetsSwitch.checked
                    }
                }
                StatusDialogDivider {
                    visible: false
                    Layout.fillWidth: true
                }
                StatusListItem {
                    Layout.fillWidth: true
                    title: qsTr("Don’t display assets with balance lower than")

                    components: [
                        CurrencyAmountInput {
                            id: currencyAmount
                            enabled: displayThresholdSwitch.checked
                            currencySymbol: root.currencySymbol
                            value: advancedSettings.getDisplayThresholdAmount()
                            onValueChanged: {
                                if (!advancedSettings.dirty && advancedSettings.getDisplayThresholdAmount() === value) {
                                    // Skipping initial value
                                    return
                                }
                                advancedSettings.dirty = true
                            }
                        },
                        StatusSwitch {
                            id: displayThresholdSwitch
                            checked: root.tokensStore.displayAssetsBelowBalance
                            onCheckedChanged: {
                                if (!advancedSettings.dirty && checked === root.tokensStore.displayAssetsBelowBalance) {
                                    // Skipping initial value
                                    return
                                }
                                advancedSettings.dirty = true
                            }
                        }
                    ]
                    onClicked: {
                        displayThresholdSwitch.checked = !displayThresholdSwitch.checked
                    }
                }
                StatusDialogDivider {
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    Layout.topMargin: 18
                    Layout.bottomMargin: -6
                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("Token lists")
                        color: Theme.palette.textColor
                    }
                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Last updated %1 @%2").arg(LocaleUtils.formatDate(root.tokenListUpdatedAt * 1000)).arg(LocaleUtils.formatTime(root.tokenListUpdatedAt, Locale.ShortFormat))
                        font.pixelSize: Theme.additionalTextSize
                        color: Theme.palette.darkGrey
                    }
                }
                SupportedTokenListsPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourcesOfTokensModel: root.sourcesOfTokensModel
                    tokensListModel: root.tokensListModel
                }
            }
        }
    }
}
