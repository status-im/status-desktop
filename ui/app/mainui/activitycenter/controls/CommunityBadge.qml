import QtQuick 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.13

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0

Badge {
    id: root

    property string communityImage
    property string communityName
    property string communityColor

    property string channelName

    signal communityNameClicked()
    signal channelNameClicked()

    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    RowLayout {
        id: layout

        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
            topMargin: 3
            bottomMargin: 3
        }

        spacing: 4

        StatusIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            icon: "tiny/community"
            color: Theme.palette.baseColor1
        }

        StatusSmartIdenticon {
            Layout.alignment: Qt.AlignVCenter
            name: root.communityName
            asset.width: 16
            asset.height: 16
            asset.letterSize: 11
            asset.color: root.communityColor
            asset.name: root.communityImage
            asset.isImage: true
        }

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            StyledTextEdit {
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignVCenter
                text: Utils.getLinkStyle(root.communityName, hoveredLink, Theme.palette.baseColor1)
                readOnly: true
                textFormat: Text.RichText
                clip: true
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                font.weight: Font.Medium
                onLinkActivated: {
                    root.communityNameClicked()
                }
            }

            StatusIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: root.channelName.length > 0
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }

            StyledTextEdit {
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignVCenter
                visible: root.channelName.length > 0
                text: Utils.getLinkStyle("#" + root.channelName, hoveredLink, Theme.palette.baseColor1)
                readOnly: true
                textFormat: Text.RichText
                clip: true
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                font.weight: Font.Medium
                onLinkActivated: {
                    root.channelNameClicked()
                }
            }
        }
    }
}
