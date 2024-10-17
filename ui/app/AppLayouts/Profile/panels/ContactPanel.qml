import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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

import AppLayouts.Profile.stores 1.0

StatusListItem {
    id: root

    width: parent.width
    height: visible ? implicitHeight : 0
    title: root.name

    property ContactsStore contactsStore

    property string name
    property string publicKey
    property string compressedPk // Needed for the tests + probably gonna be used more in the future
    property string iconSource
    property bool ensVerified

    property bool isContact: false
    property bool isBlocked: false
    property bool isVerified: false
    property bool isUntrustworthy: false
    property int verificationRequestStatus: 0

    property bool showSendMessageButton: false
    property bool showRejectContactRequestButton: false
    property bool showAcceptContactRequestButton: false
    property bool showRemoveRejectionButton: false
    property string contactText: ""
    property bool contactTextClickable: false

    signal openContactContextMenu(string publicKey, string name, string icon)
    signal sendMessageActionTriggered(string publicKey)
    signal showVerificationRequest(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)
    signal textClicked(string publicKey)

    subTitle: root.ensVerified ? "" :  Utils.getElidedCompressedPk(root.publicKey)

    asset.width: 40
    asset.height: 40
    asset.color: Utils.colorForPubkey(root.publicKey)
    asset.letterSize: asset._twoLettersSize
    asset.charactersLen: 2
    asset.name: root.iconSource
    asset.isLetterIdenticon: root.iconSource.toString() === ""
    ringSettings {
        ringSpecModel: Utils.getColorHashAsJson(root.publicKey, root.ensVerified)
        ringPxSize: Math.max(asset.width / 24.0)
    }

    components: [
        StatusFlatRoundButton {
            objectName: "chatBtn"
            visible: showSendMessageButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "chat"
            icon.color: Theme.palette.directColor1
            onClicked: root.sendMessageActionTriggered(root.publicKey)
        },
        StatusFlatRoundButton {
            objectName: "declineBtn"
            visible: showRejectContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "close-circle"
            icon.color: Theme.palette.dangerColor1
            onClicked: root.contactRequestRejected(root.publicKey)
        },
        StatusFlatRoundButton {
            objectName: "acceptBtn"
            visible: showAcceptContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "checkmark-circle"
            icon.color: Theme.palette.successColor1
            onClicked: root.contactRequestAccepted(root.publicKey)
        },
        StatusFlatRoundButton {
            objectName: "removeRejectBtn"
            visible: showRemoveRejectionButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "cancel"
            icon.color: Theme.palette.dangerColor1
            onClicked: root.rejectionRemoved(root.publicKey)
        },
        StatusBaseText {
            text: root.contactText
            anchors.verticalCenter: parent.verticalCenter
            color: root.contactTextClickable? Theme.palette.directColor1 : Theme.palette.baseColor1

            MouseArea {
                anchors.fill: parent
                enabled: root.contactTextClickable
                cursorShape: sensor.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: true
                onClicked: {
                    root.textClicked(root.publicKey)
                }
            }
        },
        StatusFlatRoundButton {
            objectName: "moreBtn"
            id: menuButton
            width: 32
            height: 32
            icon.name: "more"
            icon.color: Theme.palette.directColor1
            onClicked: {
                root.openContactContextMenu(root.publicKey, root.name, root.iconSource)
            }
        }
    ]
}
