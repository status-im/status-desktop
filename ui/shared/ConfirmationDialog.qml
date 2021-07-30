import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared/status"
import "./"

ModalPopup {
    id: confirmationDialog

    property Popup parentPopup
    property string btnType: "warn"
    property bool showCancelButton: false
    property alias checkbox: checkbox


    height: 186
    width: 400
    //% "Confirm your action"
    title: qsTrId("confirm-your-action")

    //% "Confirm"
    property string confirmButtonLabel: qsTrId("close-app-button")
    //% "Cancel"
    //% "Cancel"
    property string cancelButtonLabel: qsTrId("browsing-cancel")
    //% "Are you sure you want to this?"
    property string confirmationText: qsTrId("are-you-sure-you-want-to-this-")

    property var value

    signal confirmButtonClicked()
    signal cancelButtonClicked()

    property var executeConfirm
    property var executeCancel

    Item {
        anchors.fill: parent

        StyledText {
            id: innerText
            text: confirmationDialog.confirmationText
            font.pixelSize: 15
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
        }

        StatusCheckBox {
            id: checkbox
            visible: false
            anchors.top: innerText.bottom
            anchors.topMargin: Style.current.halfPadding
            Layout.preferredWidth: parent.width
            //% "Do not show this again"
            text: qsTrId("do-not-show-this-again")
        }
    }


    footer: Item {
        id: footerContainer
        width: parent.width
        height: confirmButton.height//children[0].height

        StatusButton {
            id: confirmButton
            type: confirmationDialog.btnType
            anchors.right: cancelButton.visible ? cancelButton.left : parent.right
            anchors.rightMargin: cancelButton.visible ? Style.current.smallPadding : 0
            text: confirmationDialog.confirmButtonLabel
            anchors.bottom: parent.bottom
            onClicked: {
                if (executeConfirm && typeof executeConfirm === "function") {
                    executeConfirm()
                }

                confirmationDialog.confirmButtonClicked()
            }
        }

        StatusButton {
            id: cancelButton
            anchors.right: parent.right
            visible: showCancelButton
            anchors.rightMargin: Style.current.smallPadding
            text: confirmationDialog.cancelButtonLabel
            anchors.bottom: parent.bottom
            onClicked: {
                if (executeCancel && typeof executeCancel === "function") {
                    executeCancel()
                }
                confirmationDialog.cancelButtonClicked()
            }
        }
    }
}



