import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import "../panels"
import "."

// TODO: replace with StatusModal
ModalPopup {
    id: blockContactConfirmationDialog
    height: 237
    width: 400

    property Popup parentPopup
    property string contactAddress: ""
    property string contactName: ""

    signal blockButtonClicked()

    title: qsTr("Block User")

    StyledText {
        text: qsTr("Blocking will stop new messages from reaching you from %1.").arg(contactName)
        font.pixelSize: 15
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
            text: qsTr("Block User")
            anchors.bottom: parent.bottom
            onClicked: blockContactConfirmationDialog.blockButtonClicked()
        }
    }
}

