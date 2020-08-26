import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

ModalPopup {
    id: confirmationDialog
    height: 186
    width: 400
    //% "Confirm your action"
    title: qsTrId("confirm-your-action")

    //% "Confirm"
    property string confirmButtonLabel: qsTrId("close-app-button")
    //% "Are you sure you want to this?"
    property string confirmationText: qsTrId("are-you-sure-you-want-to-this-")
    signal confirmButtonClicked()

    Text {
        text: confirmationDialog.confirmationText
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
            label: confirmationDialog.confirmButtonLabel
            anchors.bottom: parent.bottom
            onClicked: confirmationDialog.confirmButtonClicked()
        }
    }
}



