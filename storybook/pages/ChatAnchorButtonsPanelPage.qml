import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.panels 1.0

SplitView {
    orientation: Qt.Vertical

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        color: Theme.palette.statusAppLayout.backgroundColor

        ChatAnchorButtonsPanel {
            id: panel

            anchors.centerIn: parent

            mentionsCount: mentionsCountSlider.value
            recentMessagesCount: recentMessagesCountSlider.value

            onMentionsButtonClicked: mentionsCountSlider.value = mentionsCountSlider.value - 1
            onRecentMessagesButtonClicked: recentMessagesCountSlider.value = 0
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        ColumnLayout {
            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "unread mentions:"
                }

                Slider {
                    id: mentionsCountSlider
                    value: 1
                    from: 0
                    to: 200
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "recent messages:"
                }

                Slider {
                    id: recentMessagesCountSlider
                    value: 0
                    from: 0
                    to: 200
                }
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/%F0%9F%92%AC-Chat%E2%8E%9CDesktop?node-id=14632-460085&t=SGTU2JeRA8ifbv2E-0
