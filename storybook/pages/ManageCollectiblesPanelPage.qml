import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qt.labs.settings 1.0

import StatusQ.Models 0.1
import StatusQ.Core 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

import QtModelsToolkit 1.0

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
