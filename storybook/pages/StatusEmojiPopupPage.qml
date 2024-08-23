import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import Storybook 1.0

import utils 1.0
import shared.status 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: d
        property string lastSelectedEmoji: "N/A"
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor3
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"
            onClicked: emojiPopup.open()
        }

        Settings {
            id: settings
            category: "EmojiPopup"
            property var recentEmojis: []
            property string skinColor
        }

        StatusEmojiPopup {
            id: emojiPopup
            height: 440
            visible: true
            modal: false
            anchors.centerIn: parent
            settings: settings
            onEmojiSelected: d.lastSelectedEmoji = emoji
        }
    }


    LogsAndControlsPanel {
        SplitView.minimumHeight: 200
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            Button {
                text: "Clear settings (reload to take effect)"
                onClicked: {
                    settings.recentEmojis = []
                    settings.skinColor = ""
                    settings.sync()
                }
            }

            Text {
                text: "Last selected: %1".arg(d.lastSelectedEmoji)
            }

            Button {
                text: "Random emoji"
                onClicked: d.lastSelectedEmoji = StatusQUtils.Emoji.getRandomEmoji()
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Popups
