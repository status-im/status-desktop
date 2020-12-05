import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

ModalPopup {
    id: unblockContactConfirmationDialog
    height: 237
    width: 400

    property Popup parentPopup
    property string contactAddress: ""
    property string contactName: ""
    
    signal unblockButtonClicked()
    
    title: qsTr("Unblock User")

    StyledText {
        text: qsTr("Unblocking will allow new messages you received from %1 to reach you.").arg(contactName)
        font.pixelSize: 15
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
    }
    

    footer: Item {
        id: footerContainer
        width: parent.width
        height: children[0].height

        StyledButton {
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            btnColor: Style.current.lightRed
            btnBorderWidth: 1
            btnBorderColor: Style.current.grey
            textColor: Style.current.red
            label: qsTr("Unblock User")
            anchors.bottom: parent.bottom
            onClicked: unblockContactConfirmationDialog.unblockButtonClicked()
        }
    }
}

