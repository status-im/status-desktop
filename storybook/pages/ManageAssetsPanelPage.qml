import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageTokensModel {
        id: assetsModel
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        Component.onCompleted: forceActiveFocus()
        ManageAssetsPanel {
            id: showcasePanel
            width: 500
            baseModel: ctrlEmptyModel.checked ? null : assetsModel
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
                text: "Random data"
                onClicked: {
                    assetsModel.clear()
                    assetsModel.randomizeData()
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

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18139-95033&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-273051&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17636-249780&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-276833&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17675-283206&mode=design&t=nqFScWLfusXBNQA5-0
