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
    }

    ctaComponent: StatusLinkText {
        text: qsTr("Learn more")
        color: Theme.palette.primaryColor1
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Normal
        onClicked:  root.readMoreClicked()
    }
}
