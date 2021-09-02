import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import "../../../../imports"
import "../../../../shared"

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    anchors.centerIn: parent

    property Popup parentPopup

    property var identicon: ""
    property var userName: ""
    property string nickname: ""
    property var fromAuthor: ""
    property var text: ""
    property var alias: ""

    readonly property int innerMargin: 20
    
    property bool isEnsVerified: false
    property bool noFooter: false
    property bool isBlocked: false
    property bool isCurrentUser: false

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)
    signal contactAdded(publicKey: string)
    signal contactRemoved(publicKey: string)

    function openPopup(showFooter, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam) {
        userName = userNameParam || ""
        nickname = nicknameParam || ""
        fromAuthor = fromAuthorParam || ""
        identicon = identiconParam || ""
        text = textParam || ""
        isEnsVerified = chatsModel.ensView.isEnsVerified(this.fromAuthor)
        isBlocked = profileModel.contacts.isContactBlocked(this.fromAuthor);
        alias = chatsModel.alias(this.fromAuthor) || ""
        isCurrentUser = profileModel.profile.pubKey === this.fromAuthor
        noFooter = !showFooter;
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
        onClicked: contentComponent.qrCodePopup.open()
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
                title: qsTr("ENS username")
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
                topPadding: 8
                bottomPadding: 12
            }

            StatusDescriptionListItem {
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
                width: parent.width
                height: 16
            }
        }

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
                profileModel.contacts.unblockContact(fromAuthor)
                unblockContactConfirmationDialog.close();
                popup.close()
                popup.contactUnblocked(fromAuthor)
            }
        }

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                profileModel.contacts.blockContact(fromAuthor)
                blockContactConfirmationDialog.close();
                popup.close()

                popup.contactBlocked(fromAuthor)
            }
        }

        ConfirmationDialog {
            id: removeContactConfirmationDialog
            title: qsTr("Remove contact")
            confirmationText: qsTr("Are you sure you want to remove this contact?")
            onConfirmButtonClicked: {
                if (profileModel.contacts.isAdded(fromAuthor)) {
                    profileModel.contacts.removeContact(fromAuthor);
                }
                removeContactConfirmationDialog.close();
                popup.close();

                popup.contactRemoved(fromAuthor);
            }
        }

        NicknamePopup {
            id: nicknamePopup
            changeUsername: function (newUsername) {
                popup.userName = newUsername
            }
            changeNickname: function (newNickname) {
                popup.nickname = newNickname
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
                    contentComponent.unblockContactConfirmationDialog.contactName = userName;
                    contentComponent.unblockContactConfirmationDialog.contactAddress = fromAuthor;
                    contentComponent.unblockContactConfirmationDialog.open();
                    return;
                }
                ontentComponent.blockContactConfirmationDialog.contactName = userName;
                contentComponent.blockContactConfirmationDialog.contactAddress = fromAuthor;
                contentComponent.blockContactConfirmationDialog.open();
            }
        },

        StatusFlatButton {
            property bool isAdded:  profileModel.contacts.isAdded(fromAuthor)
            visible: !isBlocked && isAdded
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                contentComponent.removeContactConfirmationDialog.parentPopup = popup;
                contentComponent.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            property bool isAdded:  profileModel.contacts.isAdded(fromAuthor)
            text: qsTr("Add to contacts")
            visible: !isBlocked && !isAdded
            onClicked: {
                profileModel.contacts.addContact(fromAuthor);
                popup.contactAdded(fromAuthor);
                popup.close();
            }
        }
    ]
}
