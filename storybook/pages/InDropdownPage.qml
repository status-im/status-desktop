import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.controls.community 1.0

import Models 1.0

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        id: pane

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ListModel {
            id: chatsModel

            ListElement {
                itemId: 0
                name: "welcome"
                isCategory: false
                color: ""
                colorId: 1
                icon: ""
            }
            ListElement {
                itemId: 1
                name: "announcements"
                isCategory: false
                color: ""
                colorId: 1
                icon: ""
            }
            ListElement {
                name: "Discussion"
                isCategory: true

                subItems: [
                    ListElement {
                        itemId: 2
                        name: "general"
                        icon: ""
                        emoji: "👋"
                    },
                    ListElement {
                        itemId: 3
                        name: "help"
                        icon: ""
                        color: ""
                        colorId: 1
                        emoji: "⚽"
                    }
                ]
            }
            ListElement {
                name: "Support"
                isCategory: true

                subItems: [
                    ListElement {
                        itemId: 4
                        name: "faq"
                        icon: ""
                        color: ""
                        colorId: 1
                    },
                    ListElement {
                        itemId: 5
                        name: "report-scam"
                        icon: ""
                        color: ""
                        colorId: 1
                    }
                ]
            }
            ListElement {
                name: "Empty"
                isCategory: true

                subItems: []
            }
        }

        InDropdown {
            parent: pane
            anchors.centerIn: parent

            communityName: "Socks"
            communityImage: ModelsData.icons.socks
            communityColor: "red"

            model: chatsModel

            onAddChannelClicked: {
                logs.logEvent("InDropdown::addChannelClicked")
            }

            onCommunitySelected: {
                logs.logEvent("InDropdown::communitySelected")
            }

            onChannelsSelected: {
                logs.logEvent("InDropdown::channelSelected", ["channels"], arguments)
            }

            onOpened: contentItem.parent.parent = pane
            Component.onCompleted: open()
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
