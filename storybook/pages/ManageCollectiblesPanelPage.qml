import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Component.onCompleted: forceActiveFocus()

        ManageCollectiblesPanel {
            id: showcasePanel
            width: 500
            baseModel: ctrlEmptyModel.checked ? null : collectiblesModel
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
                text: "Dirty: %1".arg(showcasePanel.dirty ? "true" : "false")
            }

            Label {
                Layout.fillWidth: true
                text: "Has saved settings: %1".arg(showcasePanel.hasSettings ? "true" : "false")
            }

            Button {
                text: "Save"
                onClicked: showcasePanel.saveSettings()
            }

            Button {
                enabled: showcasePanel.dirty
                text: "Revert"
                onClicked: showcasePanel.revert()
            }

            Button {
                enabled: false
                text: "Random data (TODO)"
                onClicked: {
                    collectiblesModel.clear()
                    collectiblesModel.randomizeData()
                }
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
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19341-250476&mode=design&t=jR53lJ7aDzVHE4hZ-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19655-204534&mode=design&t=jR53lJ7aDzVHE4hZ-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19622-173583&mode=design&t=jR53lJ7aDzVHE4hZ-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19622-179146&mode=design&t=jR53lJ7aDzVHE4hZ-0
