import QtCore
import QtQuick

import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Models

import AppLayouts.Wallet.panels
import AppLayouts.Wallet.stores

import utils

import QtModelsToolkit

import Storybook
import Models
import Mocks

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    readonly property WalletAssetsStoreMock walletAssetStore: WalletAssetsStoreMock {
    }

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    RolesRenamingModel {
        id: renamedModel
        sourceModel: collectiblesModel
        mapping: [
            RoleRename {
                from: "uid"
                to: "key"
            }
        ]
    }

    ManageTokensController {
        id: assetsController
        sourceModel: ctrlEmptyModel.checked ? null : walletAssetStore.groupedAccountAssetsModel
        settingsKey: "WalletAssets"
        serializeAsCollectibles: false

        onRequestSaveSettings: (jsonData) => {
            savingStarted()
            assetsSettingsStore.setValue(settingsKey, jsonData)
            savingFinished()
        }
        onRequestLoadSettings: {
            loadingStarted()
            const jsonData = assetsSettingsStore.value(settingsKey, null)
            loadingFinished(jsonData)
        }
        onRequestClearSettings: {
            assetsSettingsStore.setValue(settingsKey, null)
        }
    }

    Settings {
        id: assetsSettingsStore
        category: "ManageTokens-" + assetsController.settingsKey
    }

    ManageTokensController {
        id: collectiblesController
        sourceModel: ctrlEmptyModel.checked ? null : renamedModel
        settingsKey: "WalletCollectibles"
        serializeAsCollectibles: true

        onRequestSaveSettings: (jsonData) => {
            savingStarted()
            collectiblesSettingsStore.setValue(settingsKey, jsonData)
            savingFinished()
        }
        onRequestLoadSettings: {
            loadingStarted()
            const jsonData = collectiblesSettingsStore.value(settingsKey, null)
            loadingFinished(jsonData)
        }
        onRequestClearSettings: {
            collectiblesSettingsStore.setValue(settingsKey, null)
        }
    }

    Settings {
        id: collectiblesSettingsStore
        category: "ManageTokens-" + collectiblesController.settingsKey
    }

    ManageHiddenPanel {
        id: showcasePanel

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        assetsController: assetsController
        collectiblesController: collectiblesController

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
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: "Has saved settings: %1".arg(showcasePanel.hasSettings ? "true" : "false")
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

            Label {
                text: "Hidden community groups:"
            }
            Label {
                text: assetsController.hiddenCommunityGroups.concat(collectiblesController.hiddenCommunityGroups).join()
            }

            Label {
                text: "Hidden collection groups:"
            }
            Label {
                text: assetsController.hiddenCollectionGroups.concat(collectiblesController.hiddenCollectionGroups).join()
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=12-126364&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=40-127902&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=577-130046&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=577-151896&mode=design&t=ZqKtOXpYtpReg4oL-0
