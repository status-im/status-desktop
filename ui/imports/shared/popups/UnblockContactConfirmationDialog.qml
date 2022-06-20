import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import "../panels"
import "./"

// TODO: replace with StatusModal
ModalPopup {
    id: unblockContactConfirmationDialog
    height: 237
    width: 400

    property Popup parentPopup
    property string contactAddress: ""
    property string contactName: ""

    signal unblockButtonClicked()

    //% "Unblock User"
    title: qsTrId("unblock-user")

    StyledText {
        //% "Unblocking will allow new messages you received from %1 to reach you."
        text: qsTrId("unblocking-will-allow-new-messages-you-received-from--1-to-reach-you-").arg(contactName)
        font.pixelSize: Style.current.primaryTextFontSize
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
    }


    footer: Item {
        id: footerContainer
        width: parent.width
        height: children[0].height

        StatusButton {
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            type: StatusBaseButton.Type.Danger
            //% "Unblock User"
            text: qsTrId("unblock-user")
            anchors.bottom: parent.bottom
            onClicked: unblockContactConfirmationDialog.unblockButtonClicked()
        }
    }
}

