import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: confirmationDialog
    anchors.centerIn: parent

    property Popup parentPopup
    property var value
    property var executeConfirm
    property var executeCancel
    property string btnType: "warn"
    property string confirmButtonLabel: qsTr("Confirm")
    property string cancelButtonLabel: qsTr("Cancel")
    property string confirmationText: qsTr("Are you sure you want to do this?")
    property bool showCancelButton: false
    property alias checkbox: checkbox


    header.title: qsTr("Confirm you action")
    focus: visible

    signal confirmButtonClicked()
    signal cancelButtonClicked()


    contentItem: Item {
        width: confirmationDialog.width
        implicitHeight: childrenRect.height
        Column {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: parent.width
                height: 16
            }

            StatusBaseText {
                text: confirmationDialog.confirmationText
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
            }

            Item {
                width: parent.width
                height: 16
            }

            StatusCheckBox {
                id: checkbox
                visible: false
                Layout.preferredWidth: parent.width
                text: qsTr("Do not show this again")
            }

            Item {
                width: parent.width
                height: visible ? 16 : 0
                visible: checkbox.visible
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            id: cancelButton
            visible: showCancelButton
            text: confirmationDialog.cancelButtonLabel
            onClicked: {
                if (executeCancel && typeof executeCancel === "function") {
                    executeCancel()
                }
                confirmationDialog.cancelButtonClicked()
            }
        },
        StatusButton {
            id: confirmButton
            type: {
                switch (confirmationDialog.btnType) {
                    case "warn":
                        return StatusBaseButton.Type.Danger
                        break
                    default:
                        return StatusBaseButton.Type.Primary
                }
            }
            text: confirmationDialog.confirmButtonLabel
            focus: true
            Keys.onReturnPressed: function(event) {
                confirmButton.clicked()
            }
            onClicked: {
                if (executeConfirm && typeof executeConfirm === "function") {
                    executeConfirm()
                }
                confirmationDialog.confirmButtonClicked()
            }
        }
    ]
}
