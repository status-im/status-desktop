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

Page {
    id: root
    Behavior on anchors.bottomMargin { NumberAnimation { duration: 30 }}

    property ListModel contactsModel: ListModel { }
    property var rootStore
    property var emojiPopup: null

    Keys.onEscapePressed: {
        Global.closeCreateChatView()
        root.rootStore.openCreateChat = false;
    }

    ListView {
        id: contactsModelListView
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.rootStore.contactsModel
        delegate: Item {
            property string pubKey: model.pubKey
            property string displayName: model.displayName
            property string icon: model.icon
        }
    }

    onVisibleChanged: {
        if (visible) {
            for (var i = 0; i < contactsModelListView.count; i ++) {
                var entry = contactsModelListView.itemAtIndex(i);
                contactsModel.insert(contactsModel.count,
                {"pubKey": entry.pubKey, "displayName": entry.displayName,
                    "icon": entry.icon});
            }
            tagSelector.sortModel(root.contactsModel);
        } else {
            contactsModel.clear();
            tagSelector.namesModel.clear();
        }
    }

    function createChat() {
        if (tagSelector.namesModel.count === 1) {
            var ensName = tagSelector.namesModel.get(0).name.includes(".eth") ? tagSelector.namesModel.get(0).name : "";
            root.rootStore.chatCommunitySectionModule.createOneToOneChat("", tagSelector.namesModel.get(0).pubKey, ensName);
        } else {
            var groupName = "";
            var pubKeys = [];
            for (var i = 0; i < tagSelector.namesModel.count; i++) {
                groupName += (tagSelector.namesModel.get(i).name + (i === tagSelector.namesModel.count - 1 ? "" : "&"));
                pubKeys.push(tagSelector.namesModel.get(i).pubKey);
            }
            root.rootStore.chatCommunitySectionModule.createGroupChat("", groupName, JSON.stringify(pubKeys));
        }

        chatInput.textInput.clear();
        chatInput.textInput.textFormat = TextEdit.PlainText;
        chatInput.textInput.textFormat = TextEdit.RichText;
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
    }

    Behavior on opacity { NumberAnimation {}}
    background: Rectangle {
        anchors.fill: parent
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
    }

    // TODO: Could it be replaced to `GroupChatPanel`?
    header: RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        height: tagSelector.height
        clip: true
        spacing: Style.current.padding
        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            maxHeight: root.height
            nameCountLimit: 20
            listLabel: contactsModel.count ? qsTr("Contacts") : ""
            textEdit.enabled: contactsModel.count
            toLabelText: qsTr("To: ")
            warningText: qsTr("USER LIMIT REACHED")
            ringSpecModelGetter: function(pubKey) {
                return Utils.getColorHashAsJson(pubKey);
            }
            compressedKeyGetter: function(pubKey) {
                return Utils.getCompressedPk(pubKey);
            }
            colorIdForPubkeyGetter: function (pubKey) {
                return Utils.colorIdForPubkey(pubKey);
            }
            onTextChanged: {
                sortModel(root.contactsModel);
            }
        }

        StatusButton {
            id: confirmButton
            implicitWidth: 106
            implicitHeight: 44
            Layout.alignment: Qt.AlignTop
            enabled: tagSelector.namesModel.count > 0
            text: qsTr("Confirm")
            onClicked: {
                root.rootStore.createChatInitMessage = chatInput.textInput.text;
                root.rootStore.createChatFileUrls = chatInput.fileUrls;
                root.createChat();
            }
        }

        Item {
            implicitHeight: 32
            implicitWidth: 32
            Layout.alignment: Qt.AlignTop

            StatusActivityCenterButton {
                id: notificationButton
                anchors.right: parent.right
                unreadNotificationsCount: activityCenter.unreadNotificationsCount
                onClicked: activityCenter.open()
            }
        }
    }

    contentItem: Item {
        StatusChatInput {
            id: chatInput
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: tagSelector.namesModel.count > 0
            chatType: tagSelector.namesModel.count == 1? Constants.chatType.oneToOne : Constants.chatType.privateGroupChat

            emojiPopup: root.emojiPopup
            recentStickers: root.rootStore.stickersModuleInst.recent
            stickerPackList: root.rootStore.stickersModuleInst.stickerPacks
            closeGifPopupAfterSelection: true

            onSendTransactionCommandButtonClicked: {
                root.rootStore.createChatStartSendTransactionProcess = true;
                root.createChat();
            }

            onReceiveTransactionCommandButtonClicked: {
                root.rootStore.createChatStartReceiveTransactionProcess = true;
                root.createChat();
            }

            onStickerSelected: {
                root.rootStore.createChatStickerHashId = hashId;
                root.rootStore.createChatStickerPackId = packId;
                root.createChat();
            }

            onSendMessage: {
                root.rootStore.createChatFileUrls = chatInput.fileUrls;
                root.rootStore.createChatInitMessage = chatInput.textInput.text;
                root.createChat();
            }
        }

        StatusBaseText {
            anchors.left: parent.left
            anchors.leftMargin: 252
            anchors.right: parent.right
            anchors.rightMargin: 252
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -(headerRow.height/2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: contactsModel.count === 0
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts.\n
Send a contact request to the person you would like to chat with, you will be able to chat with them once they have accepted your contact request.")
            Component.onCompleted: {
                if (visible) {
                    tagSelector.enabled = false;
                }
            }
        }
    }
}
