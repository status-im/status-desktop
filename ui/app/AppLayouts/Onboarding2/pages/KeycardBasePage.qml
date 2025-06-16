import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

OnboardingPage {
    id: root

    property string subtitle
    property alias image: image
    property alias infoText: infoText
    property alias buttons: buttonsColumn.children

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent

            width: Math.min(400, root.availableWidth)
            spacing: 20

            StatusImage {
                id: image
                Layout.preferredWidth: 280
                Layout.preferredHeight: 280
                Layout.alignment: Qt.AlignHCenter
                mipmap: true
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: root.subtitle
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: !!text
            }
            StatusBaseText {
                Layout.fillWidth: true
                id: infoText
                textFormat: Text.RichText
                font.pixelSize: Theme.tertiaryTextFontSize
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
                horizontalAlignment: Text.AlignHCenter
                visible: !!text
                onLinkActivated: openLinkWithConfirmation(link, SQUtils.StringUtils.extractDomainFromLink(link))

                HoverHandler {
                    // Qt CSS doesn't support custom cursor shape
                    cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                }
            }
            Column {
                id: buttonsColumn

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4

                spacing: 12
            }
        }
    }
}
