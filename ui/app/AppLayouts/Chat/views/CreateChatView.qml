import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import QtGraphicalEffects 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.status 1.0
import shared.controls.delegates 1.0

Page {
    id: root

    property var rootStore
    property var createChatPropertiesStore
    property var emojiPopup: null
    property var stickersPopup: null

    QtObject {
        id: d

        function createChat() {
            root.createChatPropertiesStore.createChatInitMessage = chatInput.textInput.text
            root.createChatPropertiesStore.createChatFileUrls = chatInput.fileUrlsAndSources
            membersSelector.createChat()

            membersSelector.cleanup()
            chatInput.textInput.clear()

            Global.closeCreateChatView()
        }
    }

    padding: 0

    Behavior on opacity { NumberAnimation {}}
    Behavior on anchors.bottomMargin { NumberAnimation { duration: 30 }}

    background: Rectangle {
        anchors.fill: parent
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
    }

    header: Item {
        implicitHeight: headerLayout.implicitHeight + headerLayout.anchors.topMargin + headerLayout.anchors.bottomMargin
        RowLayout {
            id: headerLayout
            anchors.fill: parent
            MembersSelectorView {
                id: membersSelector
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Style.current.halfPadding
                Layout.rightMargin: Style.current.halfPadding
                rootStore: root.rootStore

                function createChat() {
                    if (model.count === 0) {
                        console.warn("Can't create chat with no members")
                        return
                    }
                    if (model.count === 1) {
                        const member = model.get(0)
                        const ensName = member.displayName.includes(".eth") ? member.displayName : ""
                        root.rootStore.chatCommunitySectionModule.createOneToOneChat("", member.pubKey, ensName)
                    } else {
                        var groupName = "";
                        var pubKeys = [];
                        for (var i = 0; i < model.count; i++) {
                            const member = model.get(i)
                            groupName += (member.displayName + (i === model.count - 1 ? "" : "&"))
                            pubKeys.push(member.pubKey)
                        }
                        root.rootStore.chatCommunitySectionModule.createGroupChat("", groupName, JSON.stringify(pubKeys))
                    }
                }

                onConfirmed: { d.createChat() }

                onRejected: {
                    cleanup()
                    Global.closeCreateChatView()
                }

                onVisibleChanged: {
                    if (visible)
                        edit.forceActiveFocus()
                }

                onEnterKeyPressed: {
                    entryAccepted(contactsList.itemAtIndex(contactsList.currentIndex));
                }

                onUpKeyPressed: {
                    contactsList.decrementCurrentIndex();
                }

                onDownKeyPressed: {
                    contactsList.incrementCurrentIndex();
                }
            }

            StatusActivityCenterButton {
                Layout.alignment: Qt.AlignVCenter
                unreadNotificationsCount: activityCenterStore.unreadNotificationsCount
                hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
                onClicked: Global.openActivityCenterPopup()
            }
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors {
                fill: parent
                topMargin: Style.current.bigPadding
                bottomMargin: Style.current.padding
                leftMargin: Style.current.halfPadding
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: Style.current.halfPadding
                visible: contactsList.visible
                font.pixelSize: 15
                text: qsTr("Contacts")
                color: Theme.palette.baseColor1
            }

            StatusListView {
                id: contactsList
                objectName: "createChatContactsList"

                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: membersSelector.suggestionsModel.count &&
                         !(membersSelector.edit.text !== "")
                implicitWidth: contentItem.childrenRect.width
                model: membersSelector.suggestionsModel
                delegate: ContactListItemDelegate {
                    width: ListView.view.width
                    highlighted: ListView.isCurrentItem
                    onClicked: membersSelector.entryAccepted(this)
                }
            }

            StatusChatInput {
                id: chatInput
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                visible: membersSelector.model.count > 0
                chatType: membersSelector.model.count === 1? Constants.chatType.oneToOne : Constants.chatType.privateGroupChat
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                closeGifPopupAfterSelection: true
                usersStore: ({
                    usersModel: membersSelector.model
                })
                onStickerSelected: {
                    root.createChatPropertiesStore.createChatStickerHashId = hashId;
                    root.createChatPropertiesStore.createChatStickerPackId = packId;
                    root.createChatPropertiesStore.createChatStickerUrl = url;
                    membersSelector.createChat();
                }

                onSendMessage: { d.createChat() }
            }
        }

        StatusBaseText {
            anchors.centerIn: parent
            width: Math.min(553, parent.width - 2 * Style.current.padding)
            visible: root.rootStore.contactsModel.count === 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts.\n
Send a contact request to the person you would like to chat with, you will be able to chat with them once they have accepted your contact request.")
        }
    }
}
