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
        objectName: "emptyChatPanelImage"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: Style.png("chat/chat@2x")
    }

    Item {
        id: links
        anchors.top: walkieTalkieImage.bottom
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        height: shareKeyLink.height
        width: childrenRect.width

        StyledText {
            id: shareKeyLink
            text: qsTr("Share your chat key")
            font.pixelSize: 15
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
            text: qsTr("or")
            font.pixelSize: 15
            color: Style.current.secondaryText
            anchors.left: shareKeyLink.right
            anchors.leftMargin: 2
            anchors.bottom: shareKeyLink.bottom
        }

        StyledText {
            id: inviteLink
            text: qsTr("invite")
            font.pixelSize: 15
            color: Style.current.blue
            anchors.left: orText.right
            anchors.leftMargin: 2
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
                    Global.openPopup(inviteFriendsPopup)
                }
            }
        }
    }

    StyledText {
        text: qsTr("friends to start messaging in Status")
        font.pixelSize: 15
        color: Style.current.secondaryText
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        anchors.top: links.bottom
    }

    Component {
        id: inviteFriendsPopup
        InviteFriendsPopup {
            rootStore: element.rootStore
            destroyOnClose: true
        }
    }
}
