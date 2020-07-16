import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../shared"
import "../../../imports"
import "./components"
import "./ChatColumn"

StackLayout {
    id: chatColumnLayout
    property int chatGroupsListViewCount: 0
    property bool isReply: false
    property var appSettings
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 300

    currentIndex:  chatsModel.activeChannelIndex > -1 && chatGroupsListViewCount > 0 ? 0 : 1

    ColumnLayout {
        spacing: 0

        RowLayout {
            id: chatTopBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            z: 60
            spacing: 0
            TopBar {}
        }

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 0
            ChatMessages {
                id: chatMessages
                messageList: chatsModel.messageList
                appSettings: chatColumnLayout.appSettings
            }
       }


        ProfilePopup {
            id: profilePopup
        }

        PopupMenu {
            id: messageContextMenu
            Action {
                id: viewProfileAction
                //% "View profile"
                text: qsTrId("view-profile")
                onTriggered: profilePopup.open()
            }
            Action {
                //% "Reply to"
                text: qsTrId("reply-to")
                onTriggered: {
                    isReply = true;
                    replyAreaContainer.setup()
                }
            }
        }
 
        Rectangle {
            id: inputArea
            color: Style.current.background
            border.width: 1
            border.color: Style.current.border
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: !isReply ? 70 : 140
            Layout.preferredHeight: height

            
            ReplyArea {
                id: replyAreaContainer
                visible: isReply
            }

            ChatInput {
                height: 40
                anchors.top: !isReply ? inputArea.top : replyAreaContainer.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }

    EmptyChat {}
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:800}
}
##^##*/
