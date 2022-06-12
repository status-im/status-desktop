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
    anchors.fill: parent
    Behavior on anchors.bottomMargin { NumberAnimation { duration: 30 }}

    property ListModel contactsModel: ListModel { }
    property var rootStore
    property var emojiPopup: null

    Keys.onEscapePressed: {
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

    Connections {
        target: rootStore
        onOpenCreateChatChanged: {
            if (root.rootStore.openCreateChat) {
                for (var i = 0; i < contactsModelListView.count; i ++) {
                    var entry = contactsModelListView.itemAtIndex(i);
                    contactsModel.insert(contactsModel.count,
                    {"pubKey": entry.pubKey, "displayName": entry.displayName,
                     "icon": entry.icon});
                }
                tagSelector.sortModel(root.contactsModel);
            } else {
                tagSelector.namesModel.clear();
                contactsModel.clear();
            }
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
            root.rootStore.chatCommunitySectionModule.createGroupChat("",groupName, JSON.stringify(pubKeys));
        }

        chatInput.textInput.clear();
        chatInput.textInput.textFormat = TextEdit.PlainText;
        chatInput.textInput.textFormat = TextEdit.RichText;
    }

    visible: (opacity > 0.01)
    onVisibleChanged: {
        if (!visible) {
            tagSelector.namesModel.clear();
        }
    }

    opacity: (root.rootStore.openCreateChat) ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation {}}
    background: Rectangle {
        anchors.fill: parent
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
    }

    // TODO: Could it be replaced to `GroupChatPanel`?
    header: RowLayout {
        id: headerRow
        width: parent.width
        height: tagSelector.height
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        clip: true
        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            maxHeight: root.height
            nameCountLimit: 20
            listLabel: qsTr("Contacts")
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
            implicitHeight: 44
            Layout.alignment: Qt.AlignTop
            enabled: (tagSelector.namesModel.count > 0)
            text: "Confirm"
            onClicked: {
                root.rootStore.createChatInitMessage = chatInput.textInput.text;
                root.rootStore.createChatFileUrls = chatInput.fileUrls;
                root.createChat();
            }
        }
    }

    contentItem: Item {
        anchors.fill: parent
        anchors.topMargin: headerRow.height + 32

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
            width: parent.width
            height: contentHeight
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: (contactsModel.count === 0)
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts.\n\n
Send a contact request to the person you would like to chat with, you will be able to
chat with them once they have accepted your contact request.")
            Component.onCompleted: {
                if (visible) {
                    tagSelector.enabled = false;
                }
            }
        }
    }
}
