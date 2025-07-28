import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared
import shared.panels
import shared.controls

import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Core.Theme

Badge {
    id: root

    signal channelNameClicked()

    property int chatType: -1
    property string name: "channelName"
    property color textColor

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 16
        height: 16
        letterSize: 11
    }

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
            icon: "tiny/group"
            color: Theme.palette.baseColor1
        }

        StatusSmartIdenticon {
            Layout.alignment: Qt.AlignVCenter
            asset: root.asset
            name: root.name
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: StatusQUtils.Emoji.parse(StatusQUtils.Utils.filterXSS(name))

            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: Theme.additionalTextSize

            StatusMouseArea {
                id: replyArea
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.channelNameClicked()
            }
        }
    }
}
