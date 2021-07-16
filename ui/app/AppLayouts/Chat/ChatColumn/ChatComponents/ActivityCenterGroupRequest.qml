import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"
import "../MessageComponents"
import "../../components"
import ".."

Item {
    width: parent.width
    height: childrenRect.height + dateGroupLbl.anchors.topMargin

    DateGroup {
        id: dateGroupLbl
        previousMessageIndex: previousNotificationIndex
        previousMessageTimestamp: previousNotificationTimestamp
        messageTimestamp: model.timestamp
        isActivityCenterMessage: true
        height: visible ? implicitHeight : 0
    }

    Rectangle {
        id: groupRequestContent
        property string timestamp: model.timestamp

        visible: {
            if (hideReadNotifications && model.read) {
                return false
            }

            return activityCenter.currentFilter === ActivityCenter.Filter.All
        }
        width: parent.width
        height: visible ? 60 : 0
        anchors.top: dateGroupLbl.bottom
        anchors.topMargin: dateGroupLbl.visible ? 4 : 0
        color: model.read ? Style.current.transparent : Utils.setColorAlpha(Style.current.blue, 0.1)

        StatusIdenticon {
            id: channelIdenticon
            height: 40
            width: 40
            chatId: model.chatId
            chatName: model.name
            chatType: Constants.chatTypePrivateGroupChat
            identicon: ""
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: nameItem
            width: childrenRect.width
            height: chatName.name
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            // TODO fix anchoring to center when there is no author
    //        anchors.top: inviteText.visible ? parent.top: undefined
    //        anchors.topMargin: inviteText.visible ? Style.current.halfPadding : 0
    //        anchors.verticalCenter: inviteText.visible ? undefined : parent.verticalCenter
            anchors.left: channelIdenticon.right
            anchors.leftMargin: Style.current.halfPadding

            SVGImage {
                id: groupImage
                width: 16
                height: 16
                anchors.verticalCenter: chatName.verticalCenter
                anchors.left: parent.left
                source: "../../../../img/channel-icon-group.svg"

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: chatName.color
                }
            }

            StyledText {
                id: chatName
                text: model.name
                anchors.left: groupImage.right
                anchors.leftMargin: 4
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            ChatTime {
                anchors.verticalCenter: chatName.verticalCenter
                anchors.left: chatName.right
                anchors.leftMargin: 4
                font.pixelSize: 10
                visible: true
                color: Style.current.secondaryText
            }
        }

        function openProfile() {
            const pk = model.author
            const userProfileImage = appMain.getProfileImage(pk)
            openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
        }

        StyledTextEdit {
            id: inviteText
            visible: !!model.author
            text: {
                if (!visible) {
                    return ""
                }

                let name = chatsModel.userNameOrAlias(model.author)
                if (name.length > 20) {
                    name = name.substring(0, 9) + "..." + name.substring(name.length - 10)
                }

                //% "%1 invited you to join the group"
                return qsTrId("-1-invited-you-to-join-the-group")
                .arg(`<style type="text/css">`+
                     `a {`+
                     `color: ${Style.current.primary};`+
                     `text-decoration: none;` +
                     `}`+
                     `</style>`+
                     `<a href="#">${name}</a>`)
            }
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.halfPadding
            anchors.left: nameItem.left
            anchors.right: buttons.left
            anchors.rightMargin: Style.current.halfPadding
            clip: true
            font.pixelSize: 15
            font.weight: Font.Medium
            readOnly: true
            selectByMouse: true
            textFormat: Text.RichText
            onLinkActivated: groupRequestContent.openProfile()
            onLinkHovered: {
                cursorShape: Qt.PointingHandCursor
            }
        }

        AcceptRejectOptionsButtons {
            id: buttons
            anchors.right: parent.right
            anchors.rightMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
            onAcceptClicked: chatsModel.activityNotificationList.acceptActivityCenterNotification(model.id)
            onDeclineClicked: chatsModel.activityNotificationList.dismissActivityCenterNotification(model.id)
            onProfileClicked: groupRequestContent.openProfile()
            onBlockClicked: {
                const pk = model.author
                blockContactConfirmationDialog.contactName = chatsModel.userNameOrAlias(pk)
                blockContactConfirmationDialog.contactAddress = pk
                blockContactConfirmationDialog.open()
            }

            BlockContactConfirmationDialog {
                id: blockContactConfirmationDialog
                onBlockButtonClicked: {
                    profileModel.contacts.blockContact(blockContactConfirmationDialog.contactAddress)
                    chatsModel.activityNotificationList.dismissActivityCenterNotification(model.id)
                    blockContactConfirmationDialog.close()
                }
            }
        }
    }
}

