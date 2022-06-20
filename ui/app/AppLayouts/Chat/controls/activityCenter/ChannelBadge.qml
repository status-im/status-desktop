import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: channelBadge

    property int realChatType: -1
    property string name: "channelName"
    property color textColor
    property string profileImage: ""

    SVGImage {
        id: channelIcon
        width: Style.dp(16)
        height: width
        fillMode: Image.PreserveAspectFit
        source: Style.svg("channel-icon-" + (realChatType === Constants.chatType.publicChat ? "public-chat" : "group"))
        anchors.left: parent.left
        anchors.verticalCenter:parent.verticalCenter
    }

    StatusSmartIdenticon {
        id: contactImage
        anchors.left: channelIcon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        image: StatusImageSettings {
            width: Style.dp(16)
            height: width
            source: profileImage
        }
        icon: StatusIconSettings {
            width: Style.dp(16)
            height: width
            letterSize: Style.dp(11)
        }
        name: channelBadge.name
    }

    StyledText {
        id: contactInfo
        text: realChatType !== Constants.chatType.publicChat ?
                  StatusQUtils.Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(name))) :
                  "#" + Utils.filterXSS(name)
        anchors.left: contactImage.right
        anchors.leftMargin: Style.dp(4)
        color: textColor
        font.weight: Font.Medium
        font.pixelSize: Style.current.additionalTextSize
        anchors.verticalCenter: parent.verticalCenter
    }
}
