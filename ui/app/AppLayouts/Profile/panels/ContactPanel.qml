import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.views 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

StatusListItem {
    id: container
    width: parent.width
    visible: container.isContact && (container.searchStr == "" || container.name.includes(container.searchStr))
    height: visible ? implicitHeight : 0
    title: container.name
    image.source: container.icon

    property string name: "Jotaro Kujo"
    property string publicKey: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isContact: false
    property bool isBlocked: false
    property bool isVerified: false
    property bool isUntrustworthy: false
    property int verificationRequestStatus: 0

    property string searchStr: ""

    property bool showSendMessageButton: false
    property bool showRejectContactRequestButton: false
    property bool showAcceptContactRequestButton: false
    property bool showRemoveRejectionButton: false
    property string contactText: ""
    property bool contactTextClickable: false

    signal openProfilePopup(string publicKey)
    signal openChangeNicknamePopup(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal showVerificationRequest(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)
    signal textClicked(string publicKey)

    components: [
        StatusFlatButton {
            visible: verificationRequestStatus === Constants.verificationStatus.verifying ||
                verificationRequestStatus === Constants.verificationStatus.verified
            width: visible ? implicitWidth : 0
            height: visible ? implicitHeight : 0
            text: verificationRequestStatus === Constants.verificationStatus.verifying ?
                qsTr("Respond to ID Request") :
                qsTr("See ID Request")
            size: StatusBaseButton.Size.Small
            onClicked: container.showVerificationRequest(container.publicKey)
        },
        StatusFlatRoundButton {
            visible: showSendMessageButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "chat"
            icon.color: Theme.palette.directColor1
            onClicked: container.sendMessageActionTriggered(container.publicKey)
        },
        StatusFlatRoundButton {
            visible: showRejectContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "close-circle"
            icon.color: Style.current.danger
            onClicked: container.contactRequestRejected(container.publicKey)
        },
        StatusFlatRoundButton {
            visible: showAcceptContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "checkmark-circle"
            icon.color: Style.current.success
            onClicked: container.contactRequestAccepted(container.publicKey)
        },
        StatusFlatRoundButton {
            visible: showRemoveRejectionButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "cancel"
            icon.color: Style.current.danger
            onClicked: container.rejectionRemoved(container.publicKey)
        },
        StatusBaseText {
            text: container.contactText
            anchors.verticalCenter: parent.verticalCenter
            color: container.contactTextClickable? Theme.palette.directColor1 : Theme.palette.baseColor1

            MouseArea {
                anchors.fill: parent
                enabled: container.contactTextClickable
                cursorShape: sensor.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: true
                onClicked: {
                    container.textClicked(container.publicKey)
                }
            }
        },
        StatusFlatRoundButton {
            id: menuButton
            width: 32
            height: 32
            icon.name: "more"
            icon.color: Theme.palette.directColor1
            onClicked: {
                highlighted = true
                contactContextMenu.popup(-contactContextMenu.width+menuButton.width, menuButton.height + 4)
            }

            StatusPopupMenu {
                id: contactContextMenu

                onClosed: {
                    menuButton.highlighted = false
                }

                ProfileHeader {
                    width: parent.width

                    displayName: container.name
                    pubkey: container.publicKey
                    icon: container.icon
                }

                Item {
                    height: 8
                }

                Separator {}

                ViewProfileMenuItem {
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.openProfilePopup(container.publicKey)
                        menuButton.highlighted = false
                    }
                }

                SendMessageMenuItem {
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.sendMessageActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                    }
                    enabled: container.isContact
                }

                StatusMenuItem {
                    text: qsTr("Rename")
                    icon.name: "edit_pencil"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.openChangeNicknamePopup(container.publicKey)
                        menuButton.highlighted = false
                    }
                    enabled: !container.isBlocked
                }
            }
        }
    ]
}

