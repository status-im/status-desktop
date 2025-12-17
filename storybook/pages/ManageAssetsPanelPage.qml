import QtCore
import QtQuick

import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Models

import utils

import AppLayouts.Wallet.panels
import AppLayouts.Wallet.stores

import Storybook
import Models
import Mocks

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    readonly property WalletAssetsStoreMock walletAssetStore: WalletAssetsStoreMock {
    }

    ManageAssetsPanel {
        id: showcasePanel

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        getCurrencyAmount: function (balance, symbol) {
            return ({
                amount: balance,
                symbol: symbol,
                displayDecimals: 2,
                stripTrailingZeroes: false
            })
        }
        getCurrentCurrencyAmount: function (balance) {
            return ({
                amount: balance,
                symbol: "USD",
                displayDecimals: 2,
                stripTrailingZeroes: false
            })
        }

        controller: ManageTokensController {
            sourceModel: ctrlEmptyModel.checked ? null : walletAssetStore.groupedAccountAssetsModel
            settingsKey: "WalletAssets"
            serializeAsCollectibles: false

            onRequestSaveSettings: (jsonData) => {
                savingStarted()
                settingsStore.setValue(settingsKey, jsonData)
                savingFinished()
            }
            onRequestLoadSettings: {
                loadingStarted()
                const jsonData = settingsStore.value(settingsKey, null)
                loadingFinished(jsonData)
            }
            onRequestClearSettings: {
                settingsStore.setValue(settingsKey, null)
            }
        }

        Settings {
            id: settingsStore
            category: "ManageTokens-" + showcasePanel.controller.settingsKey
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: "Dirty: %1 (rev %2)".arg(showcasePanel.dirty ? "true" : "false").arg(showcasePanel.controller.revision)
            }

            Label {
                Layout.fillWidth: true
                text: "Has saved settings: %1".arg(showcasePanel.hasSettings ? "true" : "false")
            }

            Button {
                enabled: showcasePanel.dirty
                text: "Save"
                onClicked: showcasePanel.saveSettings(false /* update */)
            }

            Button {
                text: "Revert"
                onClicked: showcasePanel.revert()
            }

            Button {
                enabled: showcasePanel.hasSettings
                text: "Clear settings"
                onClicked: showcasePanel.clearSettings()
            }

            Switch {
                id: ctrlEmptyModel
                text: "Empty model"
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18139-95033&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-273051&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17636-249780&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-276833&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17675-283206&mode=design&t=nqFScWLfusXBNQA5-0
