import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

Column {
    id: root
    spacing: Theme.padding
    anchors.horizontalCenter: parent.horizontalCenter
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
            color: root.chatType === Constants.chatType.oneToOne ? Utils.colorForPubkey(root.chatId) : root.chatColor
            emoji: root.chatEmoji
            name: root.chatIcon
            isImage: true
            charactersLen: root.chatType === Constants.chatType.oneToOne ? 2 : 1
        }
        ringSettings.ringSpecModel: root.chatType === Constants.chatType.oneToOne ? Utils.getColorHashAsJson(root.chatId) : undefined
    }

    StyledText {
        id: channelName
        objectName: "channelIdentifierNameText"
        width: parent.width
        wrapMode: Text.Wrap
        text: root.chatName
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSize22
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
