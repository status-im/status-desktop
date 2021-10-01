import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0
import "../../../../../shared"
import "../../../../../shared/panels"
import "../../../../../shared/status"

Item {
    id: channelBadge

    property int realChatType: -1
    property string name: "channelName"
    property color textColor
    property string chatId: ""
    property string profileImage: ""
    property string identicon

    SVGImage {
        id: channelIcon
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: Style.svg("channel-icon-" + (realChatType === Constants.chatTypePublic ? "public-chat" : "group"))
        anchors.left: parent.left
        anchors.verticalCenter:parent.verticalCenter
    }

    StatusIdenticon {
        id: contactImage
        height: 16
        width: 16
        chatId: chatId
        chatName: name
        chatType: realChatType
        identicon: profileImage || identicon
        anchors.left: channelIcon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        letterSize: 11
    }

    StyledText {
        id: contactInfo
        text: realChatType !== Constants.chatTypePublic ?
                  Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(name))) :
                  "#" + Utils.filterXSS(name)
        anchors.left: contactImage.right
        anchors.leftMargin: 4
        color: textColor
        font.weight: Font.Medium
        font.pixelSize: 13
        anchors.verticalCenter: parent.verticalCenter
    }
}
