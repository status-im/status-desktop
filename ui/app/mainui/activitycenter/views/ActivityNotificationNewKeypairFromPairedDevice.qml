import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

ActivityNotificationBase {
    id: root

    ctaComponent: StatusLinkText {
        text: qsTr("View keypair import options")
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
            Layout.leftMargin: Style.current.padding
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
                displayNameLabel.text: qsTr("New keypair added")
                timestamp: root.notification.timestamp
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("%1 keypair was added to one of your synced devices").arg(root.notification.message.unparsedText)
                font.italic: true
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
            }
        }
    }
}
