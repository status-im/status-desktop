import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusChatListAndCategories {
            anchors.centerIn: parent
            width: ctrlWidth.value

            model: ListModel {
                ListElement {
                    itemId: "id1"
                    position: 0
                    name: "X"
                    subItems: []
                    isCategory: false
                    categoryId: ""
                    active: true
                    notificationsCount: 12
                    hasUnreadMessages: false
                    color: ""
                    colorId: 1
                    icon: ""
                    muted: false
                    type: StatusChatListItem.Type.CommunityChat
                }
                ListElement {
                    itemId: "id2"
                    position: 0
                    categoryPosition: 0
                    categoryId: "id2"
                    name: "Y"
                    icon: ""
                    isCategory: true
                    muted: false
                    subItems: [
                        ListElement {
                            itemId: "id3"
                            position: 0
                            name: "Y_1"
                            subItems: []
                            active: true
                            notificationsCount: 0
                            hasUnreadMessages: false
                            color: ""
                            colorId: 1
                            icon: ""
                            muted: false
                        },
                        ListElement {
                            itemId: "id4"
                            position: 1
                            name: "Y_2"
                            active: true
                            notificationsCount: 1
                            hasUnreadMessages: true
                            color: ""
                            colorId: 2
                            icon: ""
                            muted: false
                        },
                        ListElement {
                            itemId: "id5"
                            position: 1
                            name: "Y_3"
                            active: true
                            notificationsCount: 1
                            hasUnreadMessages: false
                            color: ""
                            colorId: 2
                            icon: ""
                            muted: true
                        }
                    ]
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        RowLayout {
            Label { text: "Width:" }
            Slider {
                id: ctrlWidth
                from: 30
                to: 600
                stepSize: 10
                value: 200 // smaller than the default 288
                ToolTip.text: ctrlWidth.value
                ToolTip.visible: ctrlWidth.pressed
            }
        }
    }
}
