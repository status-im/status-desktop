import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userName: ""
    property string userNickname: ""
    property string userEnsName: ""
    property string userIcon: ""
    property string text: ""

    property bool userIsEnsVerified: false
    property bool userIsBlocked: false
    property bool isCurrentUser: false
    property bool isAddedContact: false

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)

    function openPopup(publicKey, openNicknamePopup) {
        // All this should be improved more, but for now we leave it like this.
        let contactDetails = Utils.getContactDetailsAsJson(publicKey)
        userPublicKey = publicKey
        userDisplayName = contactDetails.displayName
        userName = contactDetails.alias
        userNickname = contactDetails.localNickname
        userEnsName = contactDetails.name
        userIcon = contactDetails.displayIcon
        userIsEnsVerified = contactDetails.ensVerified
        userIsBlocked = contactDetails.isBlocked
        isAddedContact = contactDetails.isContact

        text = "" // this is most likely unneeded
        isCurrentUser = popup.profileStore.pubkey === publicKey
        showFooter = !isCurrentUser
        popup.open()

        if (openNicknamePopup) {
            nicknamePopup.open()
        }
    }

    header.title: userDisplayName + qsTr("'s Profile")
    header.subTitle: userIsEnsVerified ? userName : Utils.getElidedCompressedPk(userPublicKey)
    header.subTitleElide: Text.ElideMiddle

    QtObject {
        id: d

        readonly property int contentSpacing: 5
        readonly property int contentMargins: 16
    }

    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "qr"
        onClicked: contentItem.qrCodePopup.open()
    }

    Component {
        id: contactTopComponent

        ProfileHeader {
            displayName: popup.userDisplayName
            pubkey: popup.userPublicKey
            icon: popup.isCurrentUser ? popup.profileStore.icon : popup.userIcon

            displayNameVisible: false
            pubkeyVisible: false
            compact: false

            imageOverlay: Item {
                visible: popup.isCurrentUser

                StatusFlatRoundButton {
                    width: 24
                    height: 24

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: -8
                    }

                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "pencil"
                    icon.color: Theme.palette.directColor1
                    icon.width: 12.5
                    icon.height: 12.5

                    onClicked: Global.openChangeProfilePicPopup()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        id: modalContent

        property alias qrCodePopup: qrCodePopup
        property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
        property alias blockContactConfirmationDialog: blockContactConfirmationDialog
        property alias removeContactConfirmationDialog: removeContactConfirmationDialog

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: d.contentMargins
        spacing: d.contentSpacing
        clip: true

        Item {
            implicitHeight: d.contentSpacing
            Layout.fillWidth: true
        }

        Loader {
            sourceComponent: contactTopComponent
            Layout.fillWidth: true
        }

        StatusBanner {
            visible: popup.userIsBlocked
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
            Layout.fillWidth: true
        }

        StatusDescriptionListItem {
            title: userIsEnsVerified ?
                qsTr("ENS username") :
                qsTr("Username")
            subTitle: userIsEnsVerified ? userEnsName : userName
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.visible = !tooltip.visible
            }
            Layout.fillWidth: true
        }

        StatusDescriptionListItem {
            title: qsTr("Chat key")
            subTitle: Utils.getCompressedPk(userPublicKey)
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.visible = !tooltip.visible
            }
            Layout.fillWidth: true
        }

        StatusDescriptionListItem {
            title: qsTr("Share Profile URL")
            subTitle: {

                let user = ""
                if (isCurrentUser) {
                    user = popup.profileStore.ensName !== "" ? popup.profileStore.ensName :
                                                                (popup.profileStore.pubkey.substring(0, 5) + "..." + popup.profileStore.pubkey.substring(popup.profileStore.pubkey.length - 5))
                } else if (userIsEnsVerified) {
                    user = userEnsName
                }

                if (user === ""){
                    user = userPublicKey.substr(0, 4) + "..." + userPublicKey.substr(userPublicKey.length - 5)
                }
                return Constants.userLinkPrefix +  user;
            }
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                let user = ""
                if (isCurrentUser) {
                    user = popup.profileStore.ensName !== "" ? popup.profileStore.ensName : popup.profileStore.pubkey
                } else {
                    user = (userEnsName !== "" ? userEnsName : userPublicKey)
                }
                popup.profileStore.copyToClipboard(Constants.userLinkPrefix + user)
                tooltip.visible = !tooltip.visible
            }
            Layout.fillWidth: true
        }

        StatusDescriptionListItem {
            visible: !isCurrentUser
            title: qsTr("Chat settings")
            subTitle: qsTr("Nickname")
            value: userNickname ? userNickname : qsTr("None")
            sensor.enabled: true
            sensor.onClicked: {
                nicknamePopup.open()
            }
            Layout.fillWidth: true
        }
    }

    // TODO: replace with StatusStackModal
    ModalPopup {
        id: qrCodePopup
        width: 320
        height: 320
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: globalUtils.qrCode(userPublicKey)
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
            popup.contactsStore.unblockContact(userPublicKey)
            unblockContactConfirmationDialog.close();
            popup.close()
            popup.contactUnblocked(userPublicKey)
        }
    }

    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            popup.contactsStore.blockContact(userPublicKey)
            blockContactConfirmationDialog.close();
            popup.close()

            popup.contactBlocked(userPublicKey)
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        header.title: qsTr("Remove contact")
        confirmationText: qsTr("Are you sure you want to remove this contact?")
        onConfirmButtonClicked: {
            if (isAddedContact) {
                popup.contactsStore.removeContact(userPublicKey);
            }
            removeContactConfirmationDialog.close();
            popup.close();
        }
    }

    NicknamePopup {
        id: nicknamePopup
        nickname: popup.userNickname
        header.subTitle: popup.header.subTitle
        header.subTitleElide: popup.header.subTitleElide
        onEditDone: {
            if(popup.userNickname !== newNickname)
            {
                popup.userNickname = newNickname;
                popup.contactsStore.changeContactNickname(userPublicKey, newNickname);
            }
            popup.close()
        }
    }

    // TODO: replace with StatusStackModal
    SendContactRequestModal {
        id: sendContactRequestModal
        anchors.centerIn: parent
        width: popup.width
        height: popup.height
        visible: false
        header.title: qsTr("Send Contact Request to") + " " + userDisplayName
        topComponent: contactTopComponent
        onAccepted: popup.contactsStore.sendContactRequest(userPublicKey, message)
        onClosed: popup.close()
    }

    rightButtons: [
        StatusFlatButton {
            text: userIsBlocked ?
                qsTr("Unblock User") :
                qsTr("Block User")
            type: StatusBaseButton.Type.Danger
            onClicked: {
                if (userIsBlocked) {
                    contentItem.unblockContactConfirmationDialog.contactName = userName;
                    contentItem.unblockContactConfirmationDialog.contactAddress = userPublicKey;
                    contentItem.unblockContactConfirmationDialog.open();
                    return;
                }
                contentItem.blockContactConfirmationDialog.contactName = userName;
                contentItem.blockContactConfirmationDialog.contactAddress = userPublicKey;
                contentItem.blockContactConfirmationDialog.open();
            }
        },

        StatusFlatButton {
            visible: !userIsBlocked && isAddedContact
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                contentItem.removeContactConfirmationDialog.parentPopup = popup;
                contentItem.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            text: qsTr("Send Contact Request")
            visible: !userIsBlocked && !isAddedContact
            onClicked: sendContactRequestModal.open()
        }
    ]
}
