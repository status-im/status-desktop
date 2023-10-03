import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.panels 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            id: wrapper
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            OverviewSettingsFooter {
                id: footer
                width: parent.width
                anchors.centerIn: parent
                isControlNode: controlNodeSwitch.checked
                isPendingOwnershipRequest: pendingOwnershipSwitch.checked
                communityName: "Socks"
                communityColor: "orange"

                onExportControlNodeClicked: logs.logEvent("OverviewSettingsFooter::onExportControlNodeClicked")
                onImportControlNodeClicked: logs.logEvent("OverviewSettingsFooter::onImportControlNodeClicked")
                onLearnMoreClicked: logs.logEvent("OverviewSettingsFooter::onLearnMoreClicked")
                onFinaliseOwnershipTransferClicked: logs.logEvent("OverviewSettingsFooter::onFinaliseOwnershipTransferClicked")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }
    
    Pane {
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true

        ColumnLayout {
            Switch {
                id: controlNodeSwitch
                text: "Control node on/off"
                checked: true
            }

            Switch {
                id: pendingOwnershipSwitch
                text: "Is there a pending transfer ownership request?"
                checked: true
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=36894-684461&mode=design&t=6k1ago8SSQ5Ip9J8-0
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=36894-684611&mode=design&t=6k1ago8SSQ5Ip9J8-0
