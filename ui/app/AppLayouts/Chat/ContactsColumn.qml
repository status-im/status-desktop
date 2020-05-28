import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.12
import "../../../imports"
import "../../../shared"
import "./components"
import "./ContactsColumn"

Item {
    // property alias chatGroupsListViewCount: chatGroupsListView.count
    property alias chatGroupsListViewCount: channelList.channelListCount
    property alias searchStr: searchText.text

    id: contactsColumn
    width: 300
    Layout.minimumWidth: 200
    Layout.fillHeight: true

    Text {
        id: title
        x: 772
        text: qsTr("Chat")
        anchors.top: parent.top
        anchors.topMargin: 17
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 17
    }

    PublicChatPopup {
        id: publicChatPopup
    }

    Rectangle {
        id: searchBox
        height: 36
        color: Theme.grey
        anchors.top: parent.top
        anchors.topMargin: 59
        radius: 8
        anchors.right: parent.right
        anchors.rightMargin: 65
        anchors.left: parent.left
        anchors.leftMargin: 16

        TextField {
            id: searchText
            placeholderText: qsTr("Search")
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 12
            background: Rectangle {
                color: "#00000000"
            }
        }

        Image {
            id: image4
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "../../img/search.svg"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                searchText.forceActiveFocus(Qt.MouseFocusReason)
            }
        }
    }

    Rectangle {
        id: addChat
        x: 183
        width: 36
        height: 36
        color: Theme.blue
        radius: 50
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 59

        Text {
            id: addChatLbl
            color: "#ffffff"
            text: qsTr("+")
            anchors.verticalCenterOffset: -1
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            lineHeight: 1
            fontSizeMode: Text.FixedSize
            font.bold: true
            font.pixelSize: 28
            state: "default"
            rotation: 0
            states: [
                State {
                    name: "default"
                    PropertyChanges {
                        target: addChatLbl
                        rotation: 0
                    }
                },
                State {
                    name: "rotated"
                    PropertyChanges {
                        target: addChatLbl
                        rotation: 45
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "default"
                    to: "rotated"
                    RotationAnimation {
                        duration: 150
                        direction: RotationAnimation.Clockwise
                        easing.type: Easing.InCubic
                    }
                },
                Transition {
                    from: "rotated"
                    to: "default"
                    RotationAnimation {
                        duration: 150
                        direction: RotationAnimation.Counterclockwise
                        easing.type: Easing.OutCubic
                    }
                }
            ]
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                addChatLbl.state = "rotated"
                let x = addChatLbl.x + addChatLbl.width / 2 - newChatMenu.width / 2
                newChatMenu.popup(x, addChatLbl.height + 10)
            }

            PopupMenu {
                id: newChatMenu
                QQC2.Action {
                    text: qsTr("Start new chat")
                    icon.source: "../../img/new_chat.svg"
                    onTriggered: {
                        console.log("TODO: Start new chat")
                    }
                }
                QQC2.Action {
                    text: qsTr("Start group chat")
                    icon.source: "../../img/group_chat.svg"
                    onTriggered: {
                        console.log("TODO: Start group chat")
                    }
                }
                QQC2.Action {
                    text: qsTr("Join public chat")
                    icon.source: "../../img/public_chat.svg"
                    onTriggered: publicChatPopup.open()
                }
                onAboutToHide: {
                    addChatLbl.state = "default"
                }
            }
        }
    }

    StackLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: searchBox.bottom
        anchors.topMargin: 16

        currentIndex: channelList.channelListCount > 0 ? 1 : 0

        EmptyView {}

        ChannelList {
            id: channelList
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:300}
}
##^##*/

