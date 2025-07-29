import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import "../panels"
import "../popups"

ActivityNotificationBase {
    id: root

    required property string communityName
    required property string communityColor
    required property string communityImage

    signal openCommunityClicked
    signal openShareAccountsClicked

    avatarComponent: StatusSmartIdenticon {
        name: root.communityName
        asset {
            width: 24
            height: width
            name: root.communityImage
            color: root.communityColor
            bgWidth: 40
            bgHeight: 40
        }
    }

    bodyComponent:
        ColumnLayout {
        spacing: Theme.halfPadding

        StatusBaseText {
            Layout.fillWidth: true
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
            text: qsTr("%1 requires you to share your Accounts").arg(root.communityName)
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("To continue to be a member of %1, you need to share your accounts").arg(root.communityName)
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
        }
    }

    ctaComponent: StatusLinkText {
        color: Theme.palette.primaryColor1
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Normal
        text: qsTr("Share")
        onClicked: {
            root.openShareAccountsClicked()
        }
    }
}
