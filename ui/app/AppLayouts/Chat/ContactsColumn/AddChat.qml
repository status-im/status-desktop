import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"
import "../components"

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
                icon.source: "../../../img/new_chat.svg"
                onTriggered: privateChatPopup.open()
            }
            QQC2.Action {
                text: qsTr("Start group chat")
                icon.source: "../../../img/group_chat.svg"
                onTriggered: {
                    console.log("TODO: Start group chat")
                }
            }
            QQC2.Action {
                text: qsTr("Join public chat")
                icon.source: "../../../img/public_chat.svg"
                onTriggered: publicChatPopup.open()
            }
            onAboutToHide: {
                addChatLbl.state = "default"
            }
        }
    }
}
