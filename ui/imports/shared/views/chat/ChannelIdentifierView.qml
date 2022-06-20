import QtQuick 2.14
import shared 1.0
import shared.panels 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1

import utils 1.0

Column {
    id: root
    spacing: Style.current.padding
    anchors.horizontalCenter: parent.horizontalCenter
    topPadding: visible ? Style.current.bigPadding : 0
    bottomPadding: visible? Style.dp(50) : 0

    property bool amIChatAdmin: false
    property string chatName: ""
    property string chatId: ""
    property int chatType: -1
    property string chatColor: ""
    property string chatEmoji: ""
    property string chatIcon: ""

    StatusSmartIdenticon {
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.chatName
        icon {
            width: Style.dp(120)
            height: Style.dp(120)
            color: root.chatType === Constants.chatType.oneToOne ? Utils.colorForPubkey(root.chatId) : root.chatColor
            emoji: root.chatEmoji
            charactersLen: root.chatType === Constants.chatType.oneToOne ? 2 : 1
        }
        image {
            width: Style.dp(120)
            height: Style.dp(120)
            source: root.chatIcon
        }
        ringSettings.ringSpecModel: root.chatType === Constants.chatType.oneToOne ? Utils.getColorHashAsJson(root.chatId) : undefined
    }

    StyledText {
        id: channelName
        wrapMode: Text.Wrap
        text: root.chatName
        font.weight: Font.Bold
        font.pixelSize: Style.dp(22)
        color: Style.current.textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: descText
        wrapMode: Text.Wrap
        anchors.horizontalCenter: parent.horizontalCenter
        width: Style.dp(310)
        text: {
            switch(root.chatType) {
                case Constants.chatType.privateGroupChat:
                    //% "Welcome to the beginning of the <span style='color: %1'>%2</span> group!"
                    return qsTrId("welcome-to-the-beginning-of-the--span-style--color---1---2--span--group-").arg(Style.current.textColor).arg(root.chatName);
                case Constants.chatType.oneToOne:
                    //% "Any messages you send here are encrypted and can only be read by you and <span style='color: %1'>%2</span>"
                    return qsTrId("any-messages-you-send-here-are-encrypted-and-can-only-be-read-by-you-and--span-style--color---1---2--span-").arg(Style.current.textColor).arg(root.chatName)
                default: return "";
            }
        }
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
    }
}
