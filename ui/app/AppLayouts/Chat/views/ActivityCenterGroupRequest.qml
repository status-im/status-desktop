import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import "../controls"
import "../panels"

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    width: parent.width
    height: childrenRect.height + dateGroupLbl.anchors.topMargin
    property var store
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

        StatusSmartIdenticon {
            id: channelIdenticon
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            name: model.name
            icon.color: Theme.palette.miscColor5
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
                source: Style.svg("channel-icon-group")

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

            ChatTimePanel {
                anchors.verticalCenter: chatName.verticalCenter
                anchors.left: chatName.right
                anchors.leftMargin: 4
                font.pixelSize: 10
                visible: true
                color: Style.current.secondaryText
                //timestamp: root.timestamp
            }
        }

        function openProfile() {
            const pk = model.author
            const userProfileImage = appMain.getProfileImage(pk)
            openProfilePopup(root.store.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
        }

        StyledTextEdit {
            id: inviteText
            visible: !!model.author
            text: {
                if (!visible) {
                    return ""
                }

                let name = root.store.chatsModelInst.userNameOrAlias(model.author)
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

        AcceptRejectOptionsButtonsPanel {
            id: buttons
            anchors.right: parent.right
            anchors.rightMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
            onAcceptClicked: root.store.chatsModelInst.activityNotificationList.acceptActivityCenterNotification(model.id)
            onDeclineClicked: root.store.chatsModelInst.activityNotificationList.dismissActivityCenterNotification(model.id)
            onProfileClicked: groupRequestContent.openProfile()
            onBlockClicked: {
                const pk = model.author
                blockContactConfirmationDialog.contactName = root.store.chatsModelInst.userNameOrAlias(pk)
                blockContactConfirmationDialog.contactAddress = pk
                blockContactConfirmationDialog.open()
            }

            BlockContactConfirmationDialog {
                id: blockContactConfirmationDialog
                onBlockButtonClicked: {
                    root.store.profileModuleInst.blockContact(blockContactConfirmationDialog.contactAddress)
                    root.store.chatsModelInst.activityNotificationList.dismissActivityCenterNotification(model.id)
                    blockContactConfirmationDialog.close()
                }
            }
        }
    }
}

