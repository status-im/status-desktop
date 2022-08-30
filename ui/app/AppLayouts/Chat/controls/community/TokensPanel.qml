import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

ColumnLayout {
    id: root

    property alias tokenName: pickerButton.text
    property url tokenImage
    property alias amount: amountInput.text

    signal pickerClicked

    spacing: 0

    StatusPickerButton {
        id: pickerButton

        Layout.fillWidth: true
        Layout.preferredHeight: 36

        bgColor: Theme.palette.baseColor5
        contentColor: Theme.palette.directColor1
        font.pixelSize: 13
        asset.name: root.tokenImage

        onClicked: pickerClicked()
    }

    StatusInput {
        id: amountInput

        Layout.fillWidth: true
        Layout.topMargin: 8
        minimumHeight: 36
        maximumHeight: 36
        topPadding: 0
        bottomPadding: 0
        font.pixelSize: 13
        rightPadding: amountText.implicitWidth + amountText.anchors.rightMargin + leftPadding
        input.placeholderText: "0"
        validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
        validators: StatusFloatValidator {  bottom: 0 }

        StatusBaseText {
            id: amountText
            anchors.right: parent.right
            anchors.rightMargin: 13
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Amount")
            color: Theme.palette.baseColor1
            font.pixelSize: 13
        }
    }
}
