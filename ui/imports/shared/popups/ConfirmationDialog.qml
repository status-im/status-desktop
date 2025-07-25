import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

StatusModal {
    id: confirmationDialog

    property var parentPopup
    property var value
    property var executeConfirm
    property var executeReject
    property var executeCancel
    property string confirmButtonObjectName: ""
    property string btnType: "warn"
    property string cancelBtnType: "warn"
    property string confirmButtonLabel: qsTr("Confirm")
    property string rejectButtonLabel: qsTr("Reject")
    property string cancelButtonLabel: qsTr("Cancel")
    property string confirmationText: qsTr("Are you sure you want to do this?")
    property bool showRejectButton: false
    property bool showCancelButton: false
    property alias checkbox: checkbox


    headerSettings.title: qsTr("Confirm your action")
    focus: visible

    signal confirmButtonClicked()
    signal rejectButtonClicked()
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
                font.pixelSize: Theme.primaryTextFontSize
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
            type: {
                switch (confirmationDialog.cancelBtnType) {
                    case "warn":
                        return StatusBaseButton.Type.Danger
                    default:
                        return StatusBaseButton.Type.Normal
                }
            }
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
            Layout.maximumWidth: confirmationDialog.availableWidth/2
            id: confirmButton
            objectName: confirmationDialog.confirmButtonObjectName
            type: {
                switch (confirmationDialog.btnType) {
                    case "warn":
                        return StatusBaseButton.Type.Danger
                    default:
                        return StatusBaseButton.Type.Normal
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
