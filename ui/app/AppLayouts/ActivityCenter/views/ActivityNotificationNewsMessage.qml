import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared.panels

ActivityNotificationBase {
    id: root

    signal readMoreClicked

    avatarComponent: SVGImage {
        source: Theme.png("status-logo-icon")
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignTop
        Layout.leftMargin: Theme.padding
    }

    bodyComponent: ColumnLayout {
        spacing: Theme.smallPadding / 2

        StatusBaseText {
            //Layout.maximumWidth: parent.width
            Layout.fillWidth: true
            text: root.notification ? root.notification.newsTitle : ""
            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.directColor1
            elide: Text.ElideRight
            font.weight: Font.Medium
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.maximumHeight: 50
            text: root.notification ? root.notification.newsDescription : ""
            font.pixelSize: Theme.additionalTextSize
            wrapMode: Text.WordWrap
            color: Theme.palette.directColor1

            elide: Text.ElideRight
        }

        StatusTimeStampLabel {
            id: timestampLabel
            timestamp: root.notification ? root.notification.timestamp : 0
        }
    }

    ctaComponent: StatusFlatButton {
        size: StatusBaseButton.Size.Small
        text: qsTr("Learn more")
        onClicked: {
            root.readMoreClicked()
        }
    }
}
