import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13


import utils 1.0
import shared 1.0
import shared.popups 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    anchors.centerIn: parent

    property Popup parentPopup

//ProfilePopup is either instantiated in some files
//and called to open via the openProfilePopup in others
//TODO ---------------------------------------
//use one PofilePopup instance and pass the store there
    property var store
    property var identicon: ""
    property var userName: ""
    property string nickname: ""
    property var fromAuthor: ""
    property var text: ""
    property var alias: ""

    readonly property int innerMargin: 20

    property bool isEnsVerified: false
    property bool isBlocked: false
    property bool isCurrentUser: false

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)
    signal contactAdded(publicKey: string)

    function openPopup(_showFooter, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam) {
        userName = userNameParam || ""
        nickname = nicknameParam || ""
        fromAuthor = fromAuthorParam || ""
        identicon = identiconParam || ""
        text = textParam || ""
        isEnsVerified = chatsModel.ensView.isEnsVerified(this.fromAuthor)
        isBlocked = popup.store.contactsModuleInst.model.isContactBlocked(this.fromAuthor);
        alias = chatsModel.alias(this.fromAuthor) || ""
        isCurrentUser = profileModel.profile.pubKey === this.fromAuthor
        showFooter = _showFooter;
        popup.open()
    }

    header.title: Utils.removeStatusEns(isCurrentUser ? profileModel.ens.preferredUsername || userName : userName)
    header.subTitle: isEnsVerified ? alias : fromAuthor
    header.subTitleElide: Text.ElideMiddle
    header.image.source: identicon

    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "qr"
        onClicked: contentItem.qrCodePopup.open()
    }

    contentItem: Item {
        width: popup.width
        height: modalContent.height

        property alias qrCodePopup: qrCodePopup
        property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
        property alias blockContactConfirmationDialog: blockContactConfirmationDialog
        property alias removeContactConfirmationDialog: removeContactConfirmationDialog

        Column {
            id: modalContent
            anchors.top: parent.top
            width: parent.width

            Item {
                height: 16
                width: parent.width
            }

            StatusDescriptionListItem {
                title: ((isCurrentUser && profileModel.ens.preferredUsername) || isEnsVerified) ? qsTr("ENS username") : qsTr("Username")
                subTitle: isCurrentUser ? profileModel.ens.preferredUsername || userName : userName
                tooltip.text: qsTr("Copy to clipboard")
                icon.name: "copy"
                iconButton.onClicked: {
                    chatsModel.copyToClipboard(userName)
                    tooltip.visible = !tooltip.visible
                }
                width: parent.width
            }

            StatusDescriptionListItem {
                title: qsTr("Chat key")
                subTitle: fromAuthor
                subTitleComponent.elide: Text.ElideMiddle
                subTitleComponent.width: 320
                subTitleComponent.font.family: Theme.palette.monoFont.name
                tooltip.text: qsTr("Copy to clipboard")
                icon.name: "copy"
                iconButton.onClicked: {
                    chatsModel.copyToClipboard(fromAuthor)
                    tooltip.visible = !tooltip.visible
                }
                width: parent.width
            }

            StatusModalDivider {
                topPadding: 12
                bottomPadding: 16
            }

            StatusDescriptionListItem {
                title: qsTr("Share Profile URL")
                subTitle: {
                    let user = ""
                    if (isCurrentUser) {
                        user = profileModel.ens.preferredUsername
                    } else {
                        if (isEnsVerified) {
                            user = userName.startsWith("@") ? userName.substring(1) : userName
                        }
                    }
                    if (user === ""){
                        user = fromAuthor.substr(0, 4) + "..." + fromAuthor.substr(fromAuthor.length - 5)
                    }
                    return Constants.userLinkPrefix +  user;
                }
                tooltip.text: qsTr("Copy to clipboard")
                icon.name: "copy"
                iconButton.onClicked: {
                    let user = ""
                    if (isCurrentUser) {
                        user = profileModel.ens.preferredUsername
                    } else {
                        if (isEnsVerified) {
                            user = userName.startsWith("@") ? userName.substring(1) : userName
                        }
                    }
                    if (user === ""){
                        user = fromAuthor
                    }

                    chatsModel.copyToClipboard(Constants.userLinkPrefix + user)
                    tooltip.visible = !tooltip.visible
                }
                width: parent.width
            }

            StatusModalDivider {
                visible: !isCurrentUser
                topPadding: 8
                bottomPadding: 12
            }

            StatusDescriptionListItem {
                visible: !isCurrentUser
                title: qsTr("Chat settings")
                subTitle: qsTr("Nickname")
                value: nickname ? nickname : qsTr("None")
                sensor.enabled: true
                sensor.onClicked: {
                    nicknamePopup.open()
                }
                width: parent.width
            }

            Item {
                visible: !isCurrentUser
                width: parent.width
                height: 16
            }
        }

        // TODO: replace with StatusModal
        ModalPopup {
            id: qrCodePopup
            width: 320
            height: 320
            Image {
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: profileModel.qrCode(fromAuthor)
                anchors.horizontalCenter: parent.horizontalCenter
                height: 212
                width: 212
                mipmap: true
                smooth: false
            }
        }

        UnblockContactConfirmationDialog {
            id: unblockContactConfirmationDialog
            onUnblockButtonClicked: {
                popup.store.contactsModuleInst.unblockContact(fromAuthor)
                unblockContactConfirmationDialog.close();
                popup.close()
                popup.contactUnblocked(fromAuthor)
            }
        }

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                popup.store.contactsModuleInst.blockContact(fromAuthor)
                blockContactConfirmationDialog.close();
                popup.close()

                popup.contactBlocked(fromAuthor)
            }
        }

        ConfirmationDialog {
            id: removeContactConfirmationDialog
            header.title: qsTr("Remove contact")
            confirmationText: qsTr("Are you sure you want to remove this contact?")
            onConfirmButtonClicked: {
                if (popup.store.contactsModuleInst.model.isAdded(fromAuthor)) {
                    popup.store.contactsModuleInst.removeContact(fromAuthor);
                }
                removeContactConfirmationDialog.close();
                popup.close();
            }
        }

        NicknamePopup {
            id: nicknamePopup
            onDoneClicked: {
                // Change username title only if it was not an ENS name
                if (isEnsVerified) {
                    popup.userName = newUsername;
                }
                popup.nickname = newNickname;
                popup.store.contactsModuleInst.changeContactNickname(fromAuthor, newNickname);
                popup.close()
                if (!!chatsModel.communities.activeCommunity) {
                    chatsModel.communities.activeCommunity.triggerMembersUpdate();
                }
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            text: isBlocked ?
                qsTr("Unblock User") :
                qsTr("Block User")
            type: StatusBaseButton.Type.Danger
            onClicked: {
                if (isBlocked) {
                    contentItem.unblockContactConfirmationDialog.contactName = userName;
                    contentItem.unblockContactConfirmationDialog.contactAddress = fromAuthor;
                    contentItem.unblockContactConfirmationDialog.open();
                    return;
                }
                contentItem.blockContactConfirmationDialog.contactName = userName;
                contentItem.blockContactConfirmationDialog.contactAddress = fromAuthor;
                contentItem.blockContactConfirmationDialog.open();
            }
        },

        StatusFlatButton {
            property bool isAdded: popup.store.contactsModuleInst.model.isAdded(fromAuthor)
            visible: !isBlocked && isAdded
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                contentItem.removeContactConfirmationDialog.parentPopup = popup;
                contentItem.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            property bool isAdded: popup.store.contactsModuleInst.model.isAdded(fromAuthor)
            text: qsTr("Add to contacts")
            visible: !isBlocked && !isAdded
            onClicked: {
                // TODO make a store for this
                contactsModule.addContact(fromAuthor)
                popup.contactAdded(fromAuthor);
                popup.close();
            }
        }
    ]
}
