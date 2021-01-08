import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Item {
    id: element
    Layout.fillHeight: true
    Layout.fillWidth: true

    Image {
        id: walkieTalkieImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "../../../../onboarding/img/chat@2x.jpg"
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
                onClicked: {
                    openProfilePopup(profileModel.profile.username, profileModel.profile.pubKey, profileModel.profile.thumbnailImage);
                }
            }
        }

        StyledText {
            id: orText
            text: qsTr("or")
            font.pixelSize: 15
            color: Style.current.darkGrey
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
                    inviteFriendsPopup.open();
                }
            }
        }
    }

    StyledText {
        text: qsTr("friends to start messaging in Status")
        font.pixelSize: 15
        color: Style.current.darkGrey
        anchors.horizontalCenter: walkieTalkieImage.horizontalCenter
        anchors.top: links.bottom
    }

    InviteFriendsPopup {
        id: inviteFriendsPopup
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:2;height:480;width:640}
}
##^##*/
