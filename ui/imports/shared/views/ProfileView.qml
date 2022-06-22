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

Rectangle {
    id: root

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: profileStore.pubkey
    property string userDisplayName: profileStore.displayName
    property string userName: profileStore.username
    property string userNickname: profileStore.details.localNickname
    property string userEnsName: profileStore.ensName
    property string userIcon: profileStore.profileLargeImage
    property string text: ""

    property bool userIsEnsVerified: profileStore.details.ensVerified
    property bool userIsBlocked: profileStore.details.isBlocked
    property bool isCurrentUser: profileStore.pubkey === userPublicKey
    property bool isAddedContact: false

    readonly property alias qrCodePopup: qrCodePopup
    readonly property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
    readonly property alias blockContactConfirmationDialog: blockContactConfirmationDialog
    readonly property alias removeContactConfirmationDialog: removeContactConfirmationDialog

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)
    signal contactAdded(publicKey: string)
    signal contactRemoved(publicKey: string)
    signal nicknameEdited(publicKey: string)

    implicitWidth: modalContent.implicitWidth
    implicitHeight: modalContent.implicitHeight

    color: Theme.palette.statusAppLayout.backgroundColor
    radius: 8

    QtObject {
        id: d
        readonly property string subTitle: root.userIsEnsVerified ? root.userName : Utils.getElidedCompressedPk(userPublicKey)
        readonly property int subTitleElide: Text.ElideMiddle
    }

    ColumnLayout {
        id: modalContent
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            implicitHeight: 16
        }

        ProfileHeader {
            Layout.fillWidth: true

            displayName: root.userDisplayName
            pubkey: root.userPublicKey
            icon: root.isCurrentUser ? root.profileStore.icon : root.userIcon

            displayNameVisible: false
            pubkeyVisible: false
            imageSize: ProfileHeader.ImageSize.Middle
            editImageButtonVisible: root.isCurrentUser
        }

        StatusBanner {
            Layout.fillWidth: true
            visible: root.userIsBlocked
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 16
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            title: root.userIsEnsVerified ? qsTr("ENS username") : qsTr("Username")
            subTitle: root.userIsEnsVerified ? root.userEnsName : root.userName
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.open();
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            title: qsTr("Chat key")
            subTitle: Utils.getCompressedPk(root.userPublicKey)
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.open();
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            title: qsTr("Share Profile URL")
            subTitle: {
                let user = ""
                if (isCurrentUser) {
                    user = root.profileStore.ensName !== "" ? root.profileStore.ensName 
                                                            : (root.profileStore.pubkey.substring(0, 5) + "..." + root.profileStore.pubkey.substring(root.profileStore.pubkey.length - 5))
                } else if (userIsEnsVerified) {
                    user = userEnsName
                }

                if (user === ""){
                    user = userPublicKey.substr(0, 4) + "..." + userPublicKey.substr(userPublicKey.length - 5)
                }
                return Constants.userLinkPrefix +  user;
            }
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                let user = ""
                if (isCurrentUser) {
                    user = root.profileStore.ensName !== "" ? root.profileStore.ensName : root.profileStore.pubkey
                } else {
                    user = (userEnsName !== "" ? userEnsName : userPublicKey)
                }
                root.profileStore.copyToClipboard(Constants.userLinkPrefix + user)
                tooltip.open();
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            visible: !isCurrentUser
            title: qsTr("Chat settings")
            subTitle: qsTr("Nickname")
            value: userNickname ? userNickname : qsTr("None")
            sensor.enabled: true
            sensor.onClicked: {
                nicknamePopup.open()
            }
        }

        Item {
            Layout.fillWidth: true
            visible: !isCurrentUser
            implicitHeight: 16
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
            root.contactsStore.unblockContact(userPublicKey)
            unblockContactConfirmationDialog.close();
            root.contactUnblocked(userPublicKey)
        }
    }

    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            root.contactsStore.blockContact(userPublicKey)
            blockContactConfirmationDialog.close();
            root.contactBlocked(userPublicKey)
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        header.title: qsTr("Remove contact")
        confirmationText: qsTr("Are you sure you want to remove this contact?")
        onConfirmButtonClicked: {
            if (isAddedContact) {
                root.contactsStore.removeContact(userPublicKey);
            }
            removeContactConfirmationDialog.close();
            root.contactRemoved(userPublicKey)
        }
    }

    NicknamePopup {
        id: nicknamePopup
        nickname: root.userNickname
        header.subTitle: d.subTitle
        header.subTitleElide: d.subTitleElide
        onEditDone: {
            if (root.userNickname !== newNickname)
            {
                root.userNickname = newNickname;
                root.contactsStore.changeContactNickname(userPublicKey, newNickname);
            }
            root.nicknameEdited(userPublicKey)
        }
    }
}
