import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

ModalPopup {
    id: removeContactConfirmationDialog
    height: 186
    width: 400
    property string contactAddress: ""
    signal removeButtonClicked()
    title: qsTrId("remove-contact")

    Text {
        text: qsTr("Are you sure you want to remove this contact?")
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
            //% "Block User"
            label: qsTrId("remove-contact")
            anchors.bottom: parent.bottom
            onClicked: removeContactConfirmationDialog.removeButtonClicked()
        }
    }
}


