import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.panels 1.0

ActivityNotificationBase {
    id: root

    signal learnMoreClicked

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

            StatusMessageHeader {
                Layout.fillWidth: true
                displayNameLabel.text: root.notification.title
                timestamp: root.notification.timestamp
            }

            RowLayout {
                spacing: Theme.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: root.notification.description
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }
            }
        }
    }

    ctaComponent: StatusFlatButton {
        size: StatusBaseButton.Size.Small
        text: qsTr("Learn more")
        onClicked: {
            root.learnMoreClicked()
        }
    }
}
