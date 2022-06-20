import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import utils 1.0

Item {
    id: element
    Layout.fillHeight: true
    Layout.fillWidth: true

    property var rootStore

    signal shareChatKeyClicked()

    Image {
        id: walkieTalkieImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        width: Style.dp(375)
        height: Style.dp(375)
        source: Style.png("chat/chat@3x")
    }

    Item {
        id: links
        anchors.top: walkieTalkieImage.bottom
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        height: shareKeyLink.height
        width: childrenRect.width

        StyledText {
            id: shareKeyLink
            //% "Share your chat key"
            text: qsTrId("share-your-chat-key")
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.blue

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: shareChatKeyClicked()
            }
        }

        StyledText {
            id: orText
            //% "or"
            text: qsTrId("or")
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.secondaryText
            anchors.left: shareKeyLink.right
            anchors.leftMargin: Style.dp(2)
            anchors.bottom: shareKeyLink.bottom
        }

        StyledText {
            id: inviteLink
            //% "invite"
            text: qsTrId("invite")
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.blue
            anchors.left: orText.right
            anchors.leftMargin: Style.dp(2)
            anchors.bottom: shareKeyLink.bottom

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    inviteFriendsPopup.open();
                }
            }
        }
    }

    StyledText {
        //% "friends to start messaging in Status"
        text: qsTrId("friends-to-start-messaging-in-status")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        anchors.top: links.bottom
    }

    InviteFriendsPopup {
        id: inviteFriendsPopup
        rootStore: element.rootStore
    }
}
