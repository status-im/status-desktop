import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Onboarding.views 1.0
import AppLayouts.Onboarding.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ProfileFetchingView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            startupStore: StartupStore {
                property QtObject currentStartupState: QtObject {
                    property string stateType: comboBox.currentText
                }

                function doPrimaryAction() {
                    logs.logEvent("StartupStore::doPrimaryAction")
                }

                function doSecondaryAction() {
                    logs.logEvent("StartupStore::doSecondaryAction")
                }

                function doTertiaryAction() {
                    logs.logEvent("StartupStore::doTertiaryAction")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    ComboBox {
        id: comboBox
        SplitView.preferredWidth: 300
        SplitView.preferredHeight: 100
        model: [ Constants.startupState.profileFetching, Constants.startupState.profileFetchingCompleted, Constants.startupState.profileFetchingError, "none" ]
    }
}
