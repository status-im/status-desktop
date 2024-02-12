import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0
import shared.stores 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.stores 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: walletAssetStore.groupedAccountsAssetsModel
    }

    ListModel {
        id: inShowcaseAssetsModel

        signal baseModelFilterConditionsMayHaveChanged()

        function setVisibilityByIndex(index, visibility) {
            if (visibility === Constants.ShowcaseVisibility.NoOne) {
                remove(index)
            } else {
                get(index).showcaseVisibility = visibility
            }
        }

        function setVisibility(symbol, visibility) {
            for (let i = 0; i < count; ++i) {
                if (get(i).symbol === symbol) {
                    setVisibilityByIndex(i, visibility)
                }
            }
        }

        function hasItemInShowcase(symbol) {
            for (let i = 0; i < count; ++i) {
                if (get(i).symbol === symbol) {
                    return true
                }
            }
            return false
        }

        function upsertItemJson(item) {
            append(JSON.parse(item))
        }
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500

        ProfileShowcaseAssetsPanel {
            id: showcasePanel
            width: 500
            baseModel: walletAssetStore.groupedAccountAssetsModel
            showcaseModel: inShowcaseAssetsModel
            addAccountsButtonVisible: !hasAllAccountsChecker.checked

            formatCurrencyAmount: function (amount, symbol) {
                return ({amount: amount,
                            symbol: symbol.toUpperCase(),
                            displayDecimals: 4,
                            stripTrailingZeroes: false})
            }

            onNavigateToAccountsTab: logs.logEvent("ProfileShowcaseAssetsPanel::onNavigateToAccountsTab")
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Button {
                text: "Reset (clear settings)"

                onClicked: showcasePanel.settings.reset()
            }

            CheckBox {
                id: hasAllAccountsChecker

                text: "Has the user already shared all of their accounts"
                checked: true
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14588-319260&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-238808&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-239912&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-240991&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A30679&mode=design&t=6rs9xMrPv4sGZKe4-1
