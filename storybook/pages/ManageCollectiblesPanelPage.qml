import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.settings

import StatusQ.Models
import StatusQ.Core

import AppLayouts.Wallet.panels

import utils

import Storybook
import Models

import QtModelsToolkit

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    RolesRenamingModel {
        id: renamedModel
        sourceModel: ctrlEmptyModel.checked ? null : collectiblesModel
        mapping: [
            RoleRename {
                from: "uid"
                to: "symbol"
            }
        ]
    }

    ManageCollectiblesPanel {
        id: showcasePanel

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        controller: ManageTokensController {
            sourceModel: renamedModel
            settingsKey: "WalletCollectibles"
            serializeAsCollectibles: true

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
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens
