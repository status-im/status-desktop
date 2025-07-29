import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import utils

ActivityNotificationBase {
    id: root

    ctaComponent: StatusLinkText {
        text: qsTr("View key pair import options")
        color: Theme.palette.primaryColor1
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Normal
        onClicked: {
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.wallet)
            root.closeActivityCenter()
        }
    }

    avatarComponent: StatusSmartIdenticon {
        asset {
            width: 24
            height: 24
            name: "wallet"
            color: Theme.palette.primaryColor1
            bgWidth: 40
            bgHeight: 40
            bgColor: Theme.palette.primaryColor3
        }
    }

    bodyComponent: ColumnLayout {
        spacing: Theme.halfPadding
        width: parent.width
        clip: true

        StatusBaseText {
            Layout.fillWidth: true
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
            text:  qsTr("New key pair added")
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("%1 key pair was added to one of your synced devices").arg(root.notification.message.unparsedText)
            wrapMode: Text.WordWrap
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
            elide: Text.ElideRight
        }
    }
}
