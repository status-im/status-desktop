import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

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

            RowLayout {
                anchors.centerIn: parent
                Button {
                    text: "Message context menu"
                    onClicked: {
                        menu1.createObject(this).popup()
                    }
                }
                Button {
                    text: "Message context menu (hide disabled items)"
                    onClicked: {
                        menu2.createObject(this).popup()
                    }
                }
                Button {
                    text: "Profile context menu"
                    onClicked: {
                        menu3.createObject(this).popup()
                    }
                }
                Button {
                    text: "Profile context menu (hide disabled items)"
                    onClicked: {
                        menu4.createObject(this).popup()
                    }
                }
            }

            Component {
                id: menu1
                MessageContextMenuView {
                    anchors.centerIn: parent
                    hideDisabledItems: false
                    onClosed: {
                        destroy()
                    }
                }
            }

            Component {
                id: menu2
                MessageContextMenuView {
                    anchors.centerIn: parent
                    hideDisabledItems: true
                    onClosed: {
                        destroy()
                    }
                }
            }

            Component {
                id: menu3
                ProfileContextMenu {
                    anchors.centerIn: parent
                    hideDisabledItems: false
                    onClosed: {
                        destroy()
                    }
                }
            }

            Component {
                id: menu4
                ProfileContextMenu {
                    anchors.centerIn: parent
                    hideDisabledItems: true
                    onClosed: {
                        destroy()
                    }
                }
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

// category: Views
