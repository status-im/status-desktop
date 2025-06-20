import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import utils 1.0

Item {
    id: element
    Layout.fillHeight: true
    Layout.fillWidth: true

    signal shareChatKeyClicked()

    Image {
        id: walkieTalkieImage
        objectName: "emptyChatPanelImage"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: Theme.png("chat/chat@2x")
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
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.primaryColor1

            StatusMouseArea {
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
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.secondaryText
            anchors.left: shareKeyLink.right
            anchors.leftMargin: 2
            anchors.bottom: shareKeyLink.bottom
        }

        StyledText {
            id: inviteLink
            text: qsTr("invite")
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.primaryColor1
            anchors.left: orText.right
            anchors.leftMargin: 2
            anchors.bottom: shareKeyLink.bottom

            StatusMouseArea {
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
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.secondaryText
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        anchors.top: links.bottom
    }

    Component {
        id: inviteFriendsPopup
        InviteFriendsPopup {
            destroyOnClose: true
        }
    }
}
