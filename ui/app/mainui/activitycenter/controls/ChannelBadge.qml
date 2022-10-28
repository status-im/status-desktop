import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Core.Theme 0.1

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
            icon: chatType === Constants.chatType.publicChat ? "tiny/public-chat"
                                                             : "tiny/group"
            color: Theme.palette.baseColor1
        }

        StatusSmartIdenticon {
            Layout.alignment: Qt.AlignVCenter
            asset: root.asset
            name: root.name
        }
        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: chatType !== Constants.chatType.publicChat ?
                      StatusQUtils.Emoji.parse(Utils.removeStatusEns(StatusQUtils.Utils.filterXSS(name))) :
                      "#" + StatusQUtils.Utils.filterXSS(name)

            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }

}
