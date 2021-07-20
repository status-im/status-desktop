import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ChatColumn"

Popup {
    property string chatId: chatsModel.channelView.activeChannel.id

    id: popup
    modal: true

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)
    width: 690
    height: {
        const noResultHeight = 122
        let minHeight = 560
        const maxHeight = parent.height - 200

        if (!searchResultContent.visible) {
            return noResultHeight
        }

        if (minHeight > maxHeight) {
            return maxHeight
        }

        if (listView.height < minHeight - noResultHeight) {
            return minHeight
        }
        if (listView.height > maxHeight - noResultHeight) {
            return maxHeight
        }
    }
    background: Rectangle {
        color: Style.current.background
        radius: 16
    }
    onOpened: {
        popupOpened = true
        searchInput.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: {
        popupOpened = false
    }
    padding: 0

    Connections {
        target: chatsModel.channelView
        onActiveChannelChanged: {
            searchInput.text = ""
        }
    }

    Item {
        id: searchHeader
        width: parent.width
        height: 64

        SVGImage {
            id: searchImage
            source: "../../../img/search.svg"
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
        }

        property var searchMessages: Backpressure.debounce(searchInput, 400, function (value) {
            chatsModel.messageView.searchMessages(value)
        })

        StyledTextField {
            id: searchInput
            anchors.left: searchImage.right
            anchors.leftMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            //% "Search"
            placeholderText: qsTrId("search")
            placeholderTextColor: Style.current.secondaryText
            selectByMouse: true
            font.pixelSize: 28
            background: Rectangle {
                color: Style.current.transparent
            }
            onTextChanged: {
                searchHeader.searchMessages(searchInput.text)
            }
        }

        Separator {
            anchors.bottom: parent.bottom
            anchors.topMargin: 0
        }
    }

    Rectangle {
        id: channelBadge
        color: Style.current.inputBackground
        border.width: 0
        radius: Style.current.radius
        height: 32
        width: childrenRect.width + 2 * inText.anchors.leftMargin
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: searchHeader.bottom
        anchors.topMargin: 12

        StyledText {
            id: inText
            //% "In:"
            text: qsTrId("in-")
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
        }

        BadgeContent {
            chatId: popup.chatId
            name: Utils.removeStatusEns(chatsModel.channelView.activeChannel.name)
            identicon: chatsModel.channelView.activeChannel.identicon
            communityId: chatsModel.channelView.activeChannel.communityId
            anchors.left: inText.right
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            hideSecondIcon: true
        }
    }

    Item {
        id: searchResultContent
        visible: chatsModel.messageView.searchResultMessageModel.count > 0
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.top: channelBadge.bottom
        anchors.topMargin: visible ? 13 : 0

        Separator {
            id: sep2
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        StyledText {
            id: sectionTitle
            //% "Messages"
            text: qsTrId("messages")
            font.pixelSize: 15
            color: Style.current.secondaryText
            anchors.top: sep2.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.bigPadding
        }

        ScrollView {
            id: scrollView
            anchors.top: sectionTitle.bottom
            anchors.topMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.smallPadding
            width: parent.width
            clip: true

            ListView{
                id: listView
                model: chatsModel.messageView.searchResultMessageModel

                delegate: Message {

                    anchors.right: undefined
                    messageId: model.messageId
                    fromAuthor: model.fromAuthor
                    chatId: model.chatId
                    userName: model.userName
                    alias: model.alias
                    localName: model.localName
                    message: model.message
                    plainText: model.plainText
                    identicon: model.identicon
                    isCurrentUser: model.isCurrentUser
                    timestamp: model.timestamp
                    sticker: model.sticker
                    contentType: model.contentType
                    outgoingStatus: model.outgoingStatus
                    responseTo: model.responseTo
                    imageClick: imagePopup.openPopup.bind(imagePopup)
                    linkUrls: model.linkUrls
                    communityId: model.communityId
                    hasMention: model.hasMention
                    stickerPackId: model.stickerPackId
                    pinnedBy: model.pinnedBy
                    pinnedMessage: model.isPinned
                    activityCenterMessage: true
                    clickMessage: function (isProfileClick) {
                        if (isProfileClick) {
                            const pk = model.fromAuthor
                            const userProfileImage = appMain.getProfileImage(pk)
                            return openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
                        }

                        popup.close()

                        positionAtMessage(model.messageId)
                    }

                    prevMessageIndex: -1
                    prevMsgTimestamp: ""
                }


            }
        }
    }
}
