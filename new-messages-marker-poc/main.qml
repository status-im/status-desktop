import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Core 1.0
import Font.Material 1.0

Window {
    id: root

    width: 800
    height: 600
    visible: true
    title: qsTr("New messages marker")

    color: "#222222"

    AppController {
        id: controller

        leftChatController: leftChatController
        rightChatController: rightChatController
    }

    SplitView {
        id: splitView

        anchors.fill: parent

        Item {
            SplitView.preferredWidth: splitView.width / 2

            Model {
                id: leftModel
            }

            ChatController {
                id: leftChatController
                model: leftModel
                shouldAddNewMessagesMarker: !leftChat.isMostRecentMessageVisible
            }

            ChatView {
                id: leftChat

                anchors {
                    fill: parent
                    margins: 8
                }

                controller: leftChatController
                newMessagesCount: leftModel.newMessagesCount
                allMessagesSeen: leftModel.allMessagesSeen
                messagesModel: leftModel.messagesModel
            }
        }

        Item {
            Model {
                id: rightModel
            }

            ChatController {
                id: rightChatController
                model: rightModel
                shouldAddNewMessagesMarker: !rightChat.isMostRecentMessageVisible
            }

            ChatView {
                id: rightChat

                anchors {
                    fill: parent
                    margins: 8
                }

                controller: rightChatController
                newMessagesCount: rightModel.newMessagesCount
                allMessagesSeen: rightModel.allMessagesSeen
                messagesModel: rightModel.messagesModel
            }
        }
    }

    IconButton {
        id: playButton
        anchors.horizontalCenter: parent.horizontalCenter
        text: Icons.icon.play
        onClicked: {
            playButton.visible = false
            controller.sendTestMessages()
        }
    }
}
