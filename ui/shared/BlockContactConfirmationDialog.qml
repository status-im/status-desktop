import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared/status"
import "./"

ModalPopup {
    id: blockContactConfirmationDialog
    height: 237
    width: 400

    property Popup parentPopup
    property string contactAddress: ""
    property string contactName: ""
    
    signal blockButtonClicked()
    
    title: qsTrId("block-user")

    StyledText {
        text: qsTr("Blocking will remove any messages you received from %1 and stop new messages from reaching you.").arg(contactName)
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
            //% "Block User"
            text: qsTrId("block-user")
            anchors.bottom: parent.bottom
            onClicked: blockContactConfirmationDialog.blockButtonClicked()
        }
    }
}

