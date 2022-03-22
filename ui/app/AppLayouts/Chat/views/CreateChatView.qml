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

    ListView {
        id: contactsModelListView
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.rootStore.contactsModel
        delegate: Item {
            property string publicId: model.pubKey
            property string name: model.name
            property string icon: model.icon
            property bool isIdenticon: model.isIdenticon
        }
    }

    Connections {
        target: rootStore
        onOpenCreateChatChanged: {
            if (root.rootStore.openCreateChat) {
                for (var i = 0; i < contactsModelListView.count; i ++) {
                    var entry = contactsModelListView.itemAtIndex(i);
                    contactsModel.insert(contactsModel.count,
                    {"publicId": entry.publicId, "name": entry.name,
                     "icon": entry.icon, "isIdenticon": entry.isIdenticon});
                }
            } else {
                tagSelector.namesModel.clear();
                contactsModel.clear();
            }
        }
    }

    function createChat() {
        if (tagSelector.namesModel.count === 1) {
            var ensName = tagSelector.namesModel.get(0).name.includes(".eth") ? tagSelector.namesModel.get(0).name : "";
            root.rootStore.chatCommunitySectionModule.createOneToOneChat("", tagSelector.namesModel.get(0).publicId, ensName);
        } else {
            var groupName = "";
            var publicIds = [];
            for (var i = 0; i < tagSelector.namesModel.count; i++) {
                groupName += (tagSelector.namesModel.get(i).name + (i === tagSelector.namesModel.count - 1 ? "" : "&"));
                publicIds.push(tagSelector.namesModel.get(i).publicId);
            }
            root.rootStore.chatCommunitySectionModule.createGroupChat("",groupName, JSON.stringify(publicIds));
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

    header: RowLayout {
        id: headerRow
        width: parent.width
        height: tagSelector.height
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8

        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            implicitHeight: 44
            toLabelText: qsTr("To: ")
            warningText: qsTr("USER LIMIT REACHED")

            //simulate model filtering, TODO this
            //makes more sense to be provided by the backend
            //figure how real implementation should look like
            property ListModel sortedList: ListModel { }
            onTextChanged: {
                sortedList.clear();
                if (text !== "") {
                    for (var i = 0; i < contactsModel.count; i++ ) {
                        var entry = contactsModel.get(i);
                        if (entry.name.toLowerCase().includes(text.toLowerCase())) {
                            sortedList.insert(sortedList.count, {"publicId": entry.publicId, "name": entry.name,
                                                  "icon": entry.icon, "isIdenticon": entry.isIdenticon});
                            userListView.model = sortedList;
                        }
                    }
                } else {
                    userListView.model = contactsModel;
                }
            }
        }

        StatusButton {
            id: confirmButton
            implicitHeight: 44
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

        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: chatInput.visible? chatInput.top : parent.bottom
            visible: (contactsModel.count > 0)

            Component.onCompleted: {
                if (visible) {
                    tagSelector.textEdit.forceActiveFocus();
                }
            }

            StatusBaseText {
                id: contactsLabel
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.leftMargin: 8
                color: Theme.palette.baseColor1
                text: qsTr("Contacts")
            }

            Control {
                width: 360
                anchors {
                    top: contactsLabel.bottom
                    topMargin: Style.current.halfPadding
                    bottom: !statusPopupMenuBackgroundContent.visible ?  parent.bottom : undefined
                }
                height: Style.current.padding + (!statusPopupMenuBackgroundContent.visible ? parent.height :
                        (((userListView.count * 64) > parent.height) ? parent.height : (userListView.count * 64)))
                x: (statusPopupMenuBackgroundContent.visible && (tagSelector.namesModel.count > 0) &&
                   ((tagSelector.textEdit.x + Style.current.bigPadding + statusPopupMenuBackgroundContent.width) < parent.width))
                   ? (tagSelector.textEdit.x + Style.current.bigPadding) : 0
                background: Rectangle {
                    id: statusPopupMenuBackgroundContent
                    anchors.fill: parent
                    visible: (tagSelector.sortedList.count > 0)
                    color: Theme.palette.statusPopupMenu.backgroundColor
                    radius: 8
                    layer.enabled: true
                    layer.effect: DropShadow {
                        width: statusPopupMenuBackgroundContent.width
                        height: statusPopupMenuBackgroundContent.height
                        x: statusPopupMenuBackgroundContent.x
                        visible: statusPopupMenuBackgroundContent.visible
                        source: statusPopupMenuBackgroundContent
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 12
                        samples: 25
                        spread: 0.2
                        color: Theme.palette.dropShadow
                    }
                }
                contentItem: ListView {
                    id: userListView
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    clip: true
                    model: contactsModel
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Item {
                        id: wrapper
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: 64
                        property bool hovered: false
                        Rectangle {
                            id: rectangle
                            anchors.fill: parent
                            anchors.rightMargin: Style.current.halfPadding
                            anchors.leftMargin: Style.current.halfPadding
                            radius: Style.current.radius
                            visible: (tagSelector.sortedList.count > 0)
                            color: (wrapper.hovered) ? Theme.palette.baseColor2 : "transparent"
                        }

                        StatusSmartIdenticon {
                            id: contactImage
                            anchors.left: parent.left
                            anchors.leftMargin: Style.current.padding
                            anchors.verticalCenter: parent.verticalCenter
                            name: model.name
                            icon: StatusIconSettings {
                                width: 28
                                height: 28
                                letterSize: 15
                            }
                            image: StatusImageSettings {
                                width: 28
                                height: 28
                                source: model.icon
                                isIdenticon: model.isIdenticon
                            }
                        }

                        StatusBaseText {
                            id: contactInfo
                            text: model.name
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.left: contactImage.right
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            color: Theme.palette.directColor1
                            font.weight: Font.Medium
                            font.pixelSize: 15
                        }

                        MouseArea {
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                wrapper.hovered = true;
                            }
                            onExited: {
                                wrapper.hovered = false;
                            }
                            onClicked: {
                                tagSelector.insertTag(model.name, model.publicId);
                            }
                        }
                    }
                }
            }
        }

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
