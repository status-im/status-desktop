import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property string text
    property string url
    property int linkType: 1

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: layout.implicitHeight + 10

    color: "transparent"
    border {
        width: 1
        color: Theme.palette.baseColor2
    }
    radius: height/2

    RowLayout {
        id: layout

        anchors.centerIn: parent

        StatusIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            icon: {
                if (root.linkType === Constants.socialLinkType.twitter) return "twitter"
                if (root.linkType === Constants.socialLinkType.personalSite) return "language"
                if (root.linkType === Constants.socialLinkType.github) return "github"
                if (root.linkType === Constants.socialLinkType.youtube) return "youtube"
                if (root.linkType === Constants.socialLinkType.discord) return "discord"
                if (root.linkType === Constants.socialLinkType.telegram) return "telegram"
                return ""
            }
            visible: icon !== ""
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            Layout.maximumWidth: 150
            text: root.linkType === Constants.socialLinkType.custom ? root.text : root.url
            color: Theme.palette.directColor4
            font.weight: Font.Medium
            elide: Text.ElideMiddle
        }
    }

    StatusToolTip {
        id: toolTip

        contentItem: RowLayout {
            StatusBaseText {
                Layout.fillHeight: true
                Layout.maximumWidth: 300
                Layout.bottomMargin: 8

                text: toolTip.text
                color: Theme.palette.white
                elide: Text.ElideMiddle
                font.pixelSize: 13
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            StatusFlatRoundButton {
                Layout.preferredHeight: 24
                Layout.preferredWidth: 24
                Layout.bottomMargin: 8
                icon.name: "copy"
                icon.width: 18
                icon.height: 18
                type: StatusFlatRoundButton.Tertiary

                onClicked: {
                    globalUtils.copyToClipboard(toolTip.text)
                    toolTip.visible = false
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: toolTip.show(root.url, -1)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
