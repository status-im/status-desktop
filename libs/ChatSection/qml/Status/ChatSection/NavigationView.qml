import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.ChatSection

import Status.Containers

Item {
    id: root

    required property var chatSectionController

    ColumnLayout {
        anchors.left: leftLine.right
        anchors.top: parent.top
        anchors.right: rightLine.left
        anchors.bottom: parent.bottom

        Label {
            text: qsTr("Chats")
        }

        LayoutSpacer {
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.chatSectionController.chatsModel

            onCurrentIndexChanged: root.chatSectionController.setCurrentChatIndex(currentIndex)

            clip: true

            delegate: ItemDelegate {
                width: ListView.view.width
                highlighted: ListView.isCurrentItem

                onClicked: ListView.view.currentIndex = index

                contentItem: ColumnLayout {
                    spacing: 4

                    RowLayout {
                        Rectangle {
                            Layout.preferredWidth: 15
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.leftMargin: 5
                            Layout.alignment: Qt.AlignVCenter

                            radius: width/2
                            color: chat.color
                        }
                        Label {
                            Layout.leftMargin: 10
                            Layout.topMargin: 5
                            Layout.rightMargin: 10
                            Layout.alignment: Qt.AlignVCenter

                            text: chat.name

                            verticalAlignment: Qt.AlignVCenter

                            elide: Label.ElideRight
                        }
                    }
                }
            }
        }
    }

    SideLine { id: leftLine; anchors.left: parent.left }
    SideLine { id: rightLine; anchors.right: parent.right }

    component SideLine: Rectangle {
        color: "black"
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
