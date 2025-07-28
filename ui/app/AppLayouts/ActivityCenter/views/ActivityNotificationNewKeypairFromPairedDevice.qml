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
        font.pixelSize: Theme.primaryTextFontSize
        font.weight: Font.Normal
        onClicked: {
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.wallet)
            root.closeActivityCenter()
        }
    }

    bodyComponent: RowLayout {
        implicitWidth: parent.width

        spacing: 8

        StatusSmartIdenticon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
            Layout.topMargin: 2

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

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            StatusMessageHeader {
                displayNameLabel.text: qsTr("New key pair added")
                timestamp: root.notification.timestamp
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("%1 key pair was added to one of your synced devices").arg(root.notification.message.unparsedText)
                font.italic: true
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
            }
        }
    }
}
