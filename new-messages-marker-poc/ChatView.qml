import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import Core 1.0
import Font.Material 1.0

Item {
    id: root

    property ChatController controller

    property alias messagesModel: messagesView.model
    property alias newMessagesCount: messagesView.newMessagesCount
    property alias recentMessagesCount: messagesView.recentMessagesCount
    property bool allMessagesSeen

    readonly property bool isMostRecentMessageVisible: chatLayout.visible && messagesView.isMostRecentMessageInViewport

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Text {
                text: !root.allMessagesSeen ? "<b>chat (%1)</b>".arg(root.newMessagesCount) : "chat"
                color: "white"
            }

            Rectangle {
                implicitHeight: 22
                implicitWidth: 22
                radius: 11
                color: messagesView.isMostRecentMessageInViewport ? "green" : "red"
            }

            IconButton {
                visible: chatLayout.visible
                text: Icons.icon.libraryPlus

                onClicked: dialog.open()
            }

            IconButton {
                id: eyeButton
                checkable: true
                text: checked ? Icons.icon.eyeOff : Icons.icon.eye
            }
        }

        ColumnLayout {
            id: chatLayout

            visible: !eyeButton.checked
            onVisibleChanged: {
                if (visible) {
                    if (messagesView.isMostRecentMessageInViewport) controller.markAllMessagesAsSeen()
                } else {
                    if (messagesView.hasMostRecentMessageBeenSeen) controller.resetNewMessagesCount()
                }
            }

            MessagesView {
                id: messagesView

                Layout.fillWidth: true
                Layout.fillHeight: true

                onHasMostRecentMessageBeenSeenChanged: if (hasMostRecentMessageBeenSeen) {
                                                           controller.markAllMessagesAsSeen()
                                                       }
            }

            ChatInput {
                id: chatInput
                Layout.fillWidth: true

                onEnterClicked: if (text !== "") {
                    controller.sendMessage(text)
                    text = ""
                }
            }
        }
    }

    Dialog {
        id: dialog

        title: qsTr("Send multiple messages")
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            for(let i = 0; i < spinBox.value; ++i) {
                controller.sendMessage("[%1] %2".arg(i).arg(dialogChatInput.text))
            }
        }

        RowLayout {
            anchors.fill: parent

            SpinBox {
                id: spinBox

                from: 1
                to: 999
                editable: true
            }

            ChatInput {
                id: dialogChatInput

                Layout.fillWidth: true
                Layout.preferredWidth: 200

                onEnterClicked: dialog.accept()
            }
        }
    }
}
