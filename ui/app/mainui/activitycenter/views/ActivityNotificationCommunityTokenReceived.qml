import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"
import "../popups"
import "../stores"

ActivityNotificationBase {
    id: root

    required property string communityName
    required property string communityImage
    required property string communityColor

    bodyComponent: RowLayout {
        spacing: 8

        StatusSmartIdenticon {
            name: root.communityName
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Style.current.padding
            Layout.topMargin: 2

            asset {
                width: 24
                height: width
                name: root.communityImage
                color: root.communityColor
                bgWidth: 40
                bgHeight: 40
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop

            RowLayout {
                StatusBaseText {
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Medium
                    font.pixelSize: Theme.primaryTextFontSize
                    wrapMode: Text.WordWrap
                    color: Theme.palette.primaryColor1
                    text: qsTr("You were airdropped community asset from %1").arg(root.communityName)
                }

                StatusTimeStampLabel {
                    id: timestamp
                    verticalAlignment: Text.AlignVCenter
                    timestamp: root.notification.timestamp
                }
            }
        }
    }

    ctaComponent: undefined
}
