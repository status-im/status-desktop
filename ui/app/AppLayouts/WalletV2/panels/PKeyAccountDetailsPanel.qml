import QtQuick 2.13

import "../../../../imports"
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

Item {
    id: root
    visible: (opacity > 0.1)

    property string emoji: "" //TBD
    property string accountName: accountNameInput.text
    property bool nameInputValid: accountNameInput.valid

    Row {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        StatusInput {
            id: accountNameInput
            width: (parent.width - 100)
            input.implicitHeight: 56
            input.placeholderText: qsTrId("enter-an-account-name...")
            label: qsTrId("account-name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: (accountNameInput.errors) ?
                                  qsTrId("you-need-to-enter-an-account-name") : ""
                }
            ]
        }
        Item {
            //emoji placeholder
            width: 80
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 11
            StatusBaseText {
                id: inputLabel
                text: "Emoji"
                font.weight: Font.Medium
                font.pixelSize: 13
                color: Style.current.textColor
            }
            Rectangle {
                width: parent.width
                height: 56
                anchors.top: inputLabel.bottom
                anchors.topMargin: 7
                radius: 10
                color: "pink"
                opacity: 0.6
            }
        }
    }
}
