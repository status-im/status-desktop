import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusModal {
    id: confirmationDialog
    anchors.centerIn: parent

    property Popup parentPopup
    property var value
    property var executeConfirm
    property var executeReject
    property var executeCancel
    property string btnType: "warn"
    property string confirmButtonLabel: qsTr("Confirm")
    property string rejectButtonLabel: qsTr("Reject")
    property string cancelButtonLabel: qsTr("Cancel")
    property string confirmationText: qsTr("Are you sure you want to do this?")
    property bool showRejectButton: false
    property bool showCancelButton: false
    property alias checkbox: checkbox


    header.title: qsTr("Confirm your action")
    focus: visible

    signal confirmButtonClicked()
    signal rejectButtonClicked()
    signal cancelButtonClicked()


    contentItem: Item {
        width: confirmationDialog.width
        implicitHeight: childrenRect.height
        Column {
            width: parent.width - Style.dp(32)
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: parent.width
                height: Style.dp(16)
            }

            StatusBaseText {
                text: confirmationDialog.confirmationText
                font.pixelSize: Style.current.primaryTextFontSize
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
            }

            Item {
                width: parent.width
                height: Style.dp(16)
            }

            StatusCheckBox {
                id: checkbox
                visible: false
                Layout.preferredWidth: parent.width
                text: qsTr("Do not show this again")
            }

            Item {
                width: parent.width
                height: visible ? Style.dp(16) : 0
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
        StatusFlatButton {
            visible: showRejectButton
            text: confirmationDialog.rejectButtonLabel
            onClicked: {
                if (executeReject && typeof executeReject === "function") {
                    executeReject()
                }
                confirmationDialog.rejectButtonClicked()
            }
        },
        StatusButton {
            id: confirmButton
            type: {
                switch (confirmationDialog.btnType) {
                    case "warn":
                        return StatusBaseButton.Type.Danger
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
