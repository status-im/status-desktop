import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import shared.popups 1.0
import utils 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popup.open()
        }

        MetricsEnablePopup {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true
            placement: ctrlPlacement.currentValue
            onSetMetricsEnabledRequested: logs.logEvent("setMetricsEnabledRequested", ["enabled"], arguments)
            onClosed: logs.logEvent("closed()")
        }

        Connections {
            target: Global
            function onPrivacyPolicyRequested() {
                logs.logEvent("Global::privacyPolicyRequested()")
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Placement:"
                }
                ComboBox {
                    Layout.preferredWidth: 200
                    id: ctrlPlacement
                    model: [
                        Constants.metricsEnablePlacement.unknown,
                        Constants.metricsEnablePlacement.welcome,
                        Constants.metricsEnablePlacement.privacyAndSecurity,
                        Constants.metricsEnablePlacement.startApp
                    ]
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}

// category: Popups

// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=24721-503547&t=a7IsC44aG7YQuInQ-0
