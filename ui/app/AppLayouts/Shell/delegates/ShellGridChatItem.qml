import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ShellGridItem {
    id: root

    property int chatType: Constants.chatType.unknown
    property int onlineStatus: Constants.onlineStatus.unknown
    property string lastMessageText

    sectionType: Constants.appSection.chat
    subtitle: chatType === Constants.chatType.privateGroupChat ? qsTr("Group Chat")
                                                               : chatType === Constants.chatType.communityChat ? qsTr("Community Chat")
                                                                                                               : qsTr("Chat")
    color: Qt.lighter(root.icon.color, 1.33)

    iconLoaderComponent: StatusSmartIdenticon {
        asset.width: root.icon.width
        asset.height: root.icon.height
        asset.letterSize: Theme.secondaryAdditionalTextSize

        asset.color: root.icon.color
        asset.name: root.chatType === Constants.chatType.oneToOne || root.chatType === Constants.chatType.privateGroupChat ? root.icon.name : ""
        asset.emoji: asset.name ? "" : root.icon.name

        name: root.title

        badge {
            visible: root.chatType === Constants.chatType.oneToOne && root.onlineStatus !== Constants.onlineStatus.unknown
            color: root.onlineStatus === Constants.onlineStatus.online ? Theme.palette.successColor1
                                                                       : Theme.palette.baseColor1
            border.width: 1
            border.color: hovered ? Qt.lighter(Theme.palette.baseColor4, 1.5) : Theme.palette.baseColor4
            implicitHeight: 10
            implicitWidth: 10
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
        }
    }

    bottomRowComponentFillsWidth: true
    bottomRowComponent: StatusBaseText {
        visible: !!root.lastMessageText
        text: root.lastMessageText
        font.pixelSize: Theme.additionalTextSize
        maximumLineCount: 1
        textFormat: Text.PlainText
        elide: Text.ElideRight
    }
}
