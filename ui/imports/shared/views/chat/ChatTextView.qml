import QtQuick 2.13
import QtGraphicalEffects 1.0

import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: root

    property string message: ""
    property var store
    property bool longChatText: true
    property bool veryLongChatText: globalUtils.plainText(message).length > Constants.limitLongChatTextCompactMode
    property bool readMore: false
    property alias textField: chatText

    signal linkActivated(url link)
    property alias hoveredLink: chatText.hoveredLink
    property bool linkHovered: chatText.hoveredLink !== ""

    z: 51

    implicitHeight: visible ? (showMoreLoader.active ? childrenRect.height - 10 : chatText.height) : 0

    // This function is to avoid the binding loop warning
    function setWidths() {
        if (longChatText) {
            root.width = 0;
            chatText.width = Qt.binding(function () {return root.width})
        } else {
            chatText.width = Qt.binding(function () {return chatText.implicitWidth})
            root.width = Qt.binding(function () {return chatText.width})
        }
    }

    Component.onCompleted: {
        root.setWidths()
    }

    StyledTextEdit {
        id: chatText
        visible: !showMoreLoader.active || root.readMore
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        font.pixelSize: Style.current.primaryTextFontSize
        readOnly: true
        selectByMouse: true
        color: Style.current.textColor
        height: root.veryLongChatText && !root.readMore ? Math.min(implicitHeight, 200) : implicitHeight
        clip: height < implicitHeight
        onLinkActivated: {
            root.linkActivated(link)

            // Not Refactored Yet
//            if(link.startsWith("#")) {
//                const channelName = link.substring(1);
//                const foundChannelObj = root.store.chatsModelInst.getChannel(channelName);

//                if (!foundChannelObj)
//                {
//                    root.store.chatsModelInst.channelView.joinPublicChat(channelName)
//                    if(root.store.chatsModelInst.communities.activeCommunity.active)
//                    {
//                        root.store.chatsModelInst.channelView.joinPublicChat(channelName)
//                        Global.changeAppSectionBySectionType(Constants.appSection.chat)
//                    }
//                    return
//                }

//                let obj = JSON.parse(foundChannelObj)

//                if(obj.chatType === -1 || obj.chatType === Constants.chatTypePublic)
//                {
//                    if(root.store.chatsModelInst.communities.activeCommunity.active) {
//                        root.store.chatsModelInst.channelView.joinPublicChat(channelName)
//                        Global.changeAppSectionBySectionType(Constants.appSection.chat)
//                    }
//                    root.store.chatsModelInst.channelView.setActiveChannel(channelName);
//                }
//                else if(obj.communityId === root.store.chatsModelInst.communities.activeCommunity.id &&
//                        obj.chatType === Constants.chatTypeCommunity &&
//                        root.store.chatsModelInst.channelView.activeChannel.id !== obj.id
//                        )
//                {
//                    root.store.chatsModelInst.channelView.setActiveChannel(channelName);
//                }

//                return
//            }

            if (link.startsWith('//')) {
                let pk = link.replace("//", "");
                Global.openProfilePopup(pk)
                return;
            }

            // Not Refactored Yet
//            const data = Utils.getLinkDataForStatusLinks(link)
//            if (data && data.callback) {
//                return data.callback()
//            }


            Global.openLink(link)
        }

        onLinkHovered: {
            cursorShape: Qt.PointingHandCursor
        }

        text: {
            if (contentType === Constants.messageContentType.stickerType) return "";
            let msg = Utils.linkifyAndXSS(message);
            if (isEmoji)
                return StatusQUtils.Emoji.parse(msg, StatusQUtils.Emoji.size.middle, StatusQUtils.Emoji.format.png);
            if (isEdited) {
                let index = msg.endsWith("code>") ? msg.length : msg.length - 4
                return Utils.getMessageWithStyle(StatusQUtils.Emoji.parse(msg.slice(0, index) + Constants.editLabel + msg.slice(index)), isCurrentUser, hoveredLink)
            }
            return Utils.getMessageWithStyle(StatusQUtils.Emoji.parse(msg), isCurrentUser, hoveredLink)
        
        }
    }

    Loader {
        id: mask
        anchors.fill: chatText
        active: showMoreLoader.active
        visible: false
        sourceComponent: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, chatText.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.85; color: "white" }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }

    Loader {
        id: opMask
        active: showMoreLoader.active && !root.readMore
        anchors.fill: chatText
        sourceComponent: OpacityMask {
            source: chatText
            maskSource: mask
        }
    }

    Loader {
        id: showMoreLoader
        active: root.veryLongChatText
        anchors.top: chatText.bottom
        anchors.topMargin: - Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: Component {
            SVGImage {
                id: emojiImage
                width: 256
                height: 44
                fillMode: Image.PreserveAspectFit
                source: Style.svg("read-more")
                z: 100
                rotation: root.readMore ? 180 : 0
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.readMore = !root.readMore
                    }
                }
            }
        }
    }
}
