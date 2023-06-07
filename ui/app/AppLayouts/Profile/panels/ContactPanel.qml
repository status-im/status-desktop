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
    id: root

    width: parent.width
    height: visible ? implicitHeight : 0
    title: root.name

    property var contactsStore

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
        StatusFlatButton {
            visible: verificationRequestStatus === Constants.verificationStatus.verifying ||
                verificationRequestStatus === Constants.verificationStatus.verified
            width: visible ? implicitWidth : 0
            height: visible ? implicitHeight : 0
            text: verificationRequestStatus === Constants.verificationStatus.verifying ?
                qsTr("Respond to ID Request") :
                qsTr("See ID Request")
            size: StatusBaseButton.Size.Small
            onClicked: root.showVerificationRequest(root.publicKey)
        },
        StatusFlatRoundButton {
            visible: showSendMessageButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "chat"
            icon.color: Theme.palette.directColor1
            onClicked: root.sendMessageActionTriggered(root.publicKey)
        },
        StatusFlatRoundButton {
            visible: showRejectContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "close-circle"
            icon.color: Style.current.danger
            onClicked: root.contactRequestRejected(root.publicKey)
        },
        StatusFlatRoundButton {
            visible: showAcceptContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "checkmark-circle"
            icon.color: Style.current.success
            onClicked: root.contactRequestAccepted(root.publicKey)
        },
        StatusFlatRoundButton {
            visible: showRemoveRejectionButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "cancel"
            icon.color: Style.current.danger
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
