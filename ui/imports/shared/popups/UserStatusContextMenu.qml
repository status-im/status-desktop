import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import "../panels"
import "."

import StatusQ.Components 0.1

// TODO: replace with StatusPopupMenu
PopupMenu {
    id: root
    property var store
    width: profileHeader.width
    closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

    Item {
        id: profileHeader
        width: 200
        height: visible ? profileImage.height + username.height + viewProfileBtn.height + Style.current.padding * 2 : 0
        Rectangle {
            anchors.fill: parent
            visible: mouseArea.containsMouse
            color: Style.current.backgroundHover
        }
        StatusSmartIdenticon {
            id: profileImage
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            image.source: userProfile.thumbnailImage || ""
            image.isIdenticon: true
        }
        StyledText {
            id: username
            text: Utils.removeStatusEns(profileModel.ens.preferredUsername || userProfile.username)
            elide: Text.ElideRight
            maximumLineCount: 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.top: profileImage.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 13
        }

        StyledText {
            id: viewProfileBtn
            text: qsTr("My profile →")
            horizontalAlignment: Text.AlignHCenter
            anchors.top: username.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Style.current.secondaryText
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                openProfilePopup(userProfile.username, userProfile.pubKey, userProfile.thumbnailImage);
                root.close()
            }
        }
    }

    Separator {
        anchors.bottom: profileHeader.bottom
    }

    overrideTextColor: Style.current.textColor

    Action {
        text: qsTr("Online")
        onTriggered: {
            if (userProfile.sendUserStatus != true) {
                root.store.profileModelInst.profile.setSendUserStatus(true)
            }
            root.close();
        }
        icon.color: Style.current.green
        icon.source: Style.svg("online")
        icon.width: 16
        icon.height: 16
    }

    Action {
        text: qsTr("Offline")
        onTriggered: {
            if (userProfile.sendUserStatus != false) {
                root.store.profileModelInst.profile.setSendUserStatus(false)
            }
            root.close();
        }

        icon.color: Style.current.midGrey
        icon.source: Style.svg("offline")
        icon.width: 16
        icon.height: 16
    }

}
