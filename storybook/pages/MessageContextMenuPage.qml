import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.views.communities 1.0

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.views.chat 1.0

SplitView {

    QtObject {
        id: d
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            StatusButton {
                anchors.centerIn: parent
                text: "Open menu"
                onClicked: {
                    messageContextMenu.open()
                }
            }

            MessageContextMenuView {
                id: messageContextMenu
                anchors.centerIn: parent
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose
                hideDisabledItems: false
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
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                spacing: 16

            }
        }
    }
}
