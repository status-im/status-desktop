import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Components

import utils
import shared
import shared.panels

Column {
    id: root
    spacing: Theme.padding
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Theme.bigPadding
    anchors.rightMargin: Theme.bigPadding
    topPadding: visible ? Theme.bigPadding : 0
    bottomPadding: visible? 50 : 0

    property bool amIChatAdmin: false
    property string chatName: ""
    property string chatId: ""
    property int chatType: -1
    property string chatColor: ""
    property string chatEmoji: ""
    property string chatIcon: ""

    StatusSmartIdenticon {
        objectName: "channelIdentifierSmartIdenticon"
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.chatName
        asset {
            width: 120
            height: 120
            color: root.chatType === Constants.chatType.oneToOne ? Utils.colorForPubkey(Theme.palette, root.chatId) : root.chatColor
            emoji: root.chatEmoji
            name: root.chatIcon
            isImage: true
            charactersLen: root.chatType === Constants.chatType.oneToOne ? 2 : 1
        }
    }

    StyledText {
        id: channelName
        objectName: "channelIdentifierNameText"
        width: parent.width
        wrapMode: Text.Wrap
        text: root.chatName
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSize(22)
        color: Theme.palette.textColor
        horizontalAlignment: Text.AlignHCenter
    }

    StatusBaseText {
        id: descText
        width: parent.width
        wrapMode: Text.Wrap
        text: {
            switch(root.chatType) {
                case Constants.chatType.privateGroupChat:
                    return qsTr("Welcome to the beginning of the <span style='color: %1'>%2</span> group!").arg(Theme.palette.textColor).arg(root.chatName);
                case Constants.chatType.communityChat:
                    return qsTr("Welcome to the beginning of the <span style='color: %1'>#%2</span> channel!").arg(Theme.palette.textColor).arg(root.chatName);
                case Constants.chatType.oneToOne:
                    return qsTr("Any messages you send here are encrypted and can only be read by you and <span style='color: %1'>%2</span>").arg(Theme.palette.textColor).arg(root.chatName)
                default: return "";
            }
        }
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.secondaryText
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
    }
}
