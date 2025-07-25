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

    bodyComponent: RowLayout {
        spacing: 8

        SVGImage {
            source: Theme.png("status-logo-icon")
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            RowLayout {
                Layout.maximumWidth: parent.width

                StatusBaseText {
                    text: root.notification ? root.notification.newsTitle : ""
                    color: Theme.palette.baseColor1
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.weight: Font.Medium
                }

                StatusTimeStampLabel {
                    id: timestampLabel
                    verticalAlignment: Text.AlignVCenter
                    timestamp: root.notification ? root.notification.timestamp : 0
                }
            }
            
            StatusBaseText {
                Layout.fillWidth: true
                text: root.notification ? root.notification.newsDescription : ""
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
                Layout.maximumHeight: 44
                elide: Text.ElideRight
            }
        }
    }

    ctaComponent: StatusFlatButton {
        size: StatusBaseButton.Size.Small
        text: qsTr("Read more")
        onClicked: {
            root.readMoreClicked()
        }
    }
}
