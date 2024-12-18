import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    width: parent.width
    height: visible ? implicitHeight : 0
    title: root.name

    property string name
    property string iconSource

    property color pubKeyColor
    property var colorHash

    property bool showSendMessageButton: false
    property bool showRejectContactRequestButton: false
    property bool showAcceptContactRequestButton: false
    property bool showRemoveRejectionButton: false
    property string contactText: ""

    signal contextMenuRequested
    signal sendMessageRequested
    signal showVerificationRequestRequested
    signal acceptContactRequested
    signal rejectRequestRequested
    signal removeRejectionRequested

    asset.width: 40
    asset.height: 40
    asset.color: root.pubKeyColor
    asset.letterSize: asset._twoLettersSize
    asset.charactersLen: 2
    asset.name: root.iconSource
    asset.isLetterIdenticon: root.iconSource.toString() === ""
    ringSettings {
        ringSpecModel: root.colorHash
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
            onClicked: root.sendMessageRequested()
        },
        StatusFlatRoundButton {
            objectName: "declineBtn"
            visible: showRejectContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "close-circle"
            icon.color: Theme.palette.dangerColor1
            onClicked: root.rejectRequestRequested()
        },
        StatusFlatRoundButton {
            objectName: "acceptBtn"
            visible: showAcceptContactRequestButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "checkmark-circle"
            icon.color: Theme.palette.successColor1
            onClicked: root.acceptContactRequested()
        },
        StatusFlatRoundButton {
            objectName: "removeRejectBtn"
            visible: showRemoveRejectionButton
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "cancel"
            icon.color: Theme.palette.dangerColor1
            onClicked: root.removeRejectionRequested()
        },
        StatusBaseText {
            text: root.contactText
            anchors.verticalCenter: parent.verticalCenter

            color: Theme.palette.baseColor1
        },
        StatusFlatRoundButton {
            objectName: "moreBtn"
            id: menuButton
            width: 32
            height: 32
            icon.name: "more"
            icon.color: Theme.palette.directColor1
            onClicked: root.contextMenuRequested()
        }
    ]
}
