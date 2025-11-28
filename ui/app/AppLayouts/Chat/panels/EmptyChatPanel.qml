import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import shared.popups

import utils

ColumnLayout {
    id: root

    signal shareChatKeyClicked()

    spacing: 0

    Image {
        id: placeholderImage

        objectName: "emptyChatPanelImage"

        fillMode: Image.PreserveAspectFit

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: Math.min(width, implicitHeight)

        Layout.topMargin: {
            const remainingHeight = root.height - height

            return Math.max(0, remainingHeight / 2 -
                            Math.max(0, baseText.implicitHeight -
                                     remainingHeight / 2)) / 2
        }

        source: Assets.png("chat/chat@2x")
    }

    StatusBaseText {
        id: baseText

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: implicitHeight

        text: qsTr("%1 or %2<br>friends to start messaging in Status")
          .arg(Utils.getStyledLink(qsTr("Share your chat key"), "#share", hoveredLink,
                Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
          .arg(Utils.getStyledLink(qsTr("invite"), "#invite", hoveredLink,
                Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))

        horizontalAlignment: Text.AlignHCenter

        color: Theme.palette.secondaryText
        font.pixelSize: Theme.primaryTextFontSize
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        maximumLineCount: 3
        textFormat: Text.RichText

        onLinkActivated: link => {
            if (link === "#share")
                shareChatKeyClicked()
            else
                Global.openPopup(inviteFriendsPopup)
        }

        HoverHandler {
            // Qt CSS doesn't support custom cursor shape
            cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
        }
    }

    Component {
        id: inviteFriendsPopup

        InviteFriendsPopup {
            destroyOnClose: true
        }
    }
}
