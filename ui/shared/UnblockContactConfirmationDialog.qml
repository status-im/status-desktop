import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared/status"
import "./"

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
            type: "warn"
            //% "Unblock User"
            text: qsTrId("unblock-user")
            anchors.bottom: parent.bottom
            onClicked: unblockContactConfirmationDialog.unblockButtonClicked()
        }
    }
}

