import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.popups.community 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            RemotelyDestructPopup {
                id: dialog

                anchors.centerIn: parent
                collectibleName: editorCollectible.text
                model: TokenHoldersModel {}

                onRemotelyDestructClicked: logs.logEvent("RemoteSelfDestructPopup::onRemotelyDestructClicked")

                Component.onCompleted: {
                    open()
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

        ColumnLayout {

            Label {
                Layout.fillWidth: true
                text: "Collectible name"
            }

            TextField {
                id: editorCollectible
                background: Rectangle { border.color: 'lightgrey' }
                Layout.preferredWidth: 200
                text: "Anniversary"
            }

        }
    }
}


