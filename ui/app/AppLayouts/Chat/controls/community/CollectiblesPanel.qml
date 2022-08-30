import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

ColumnLayout {
    id: root

    property alias specificAmount: specificAmountSwitch.checked
    property alias collectibleName: pickerButton.text
    property url collectibleImage

    property alias amount: amountInput.text

    signal pickerClicked

    spacing: 0

    StatusPickerButton {
        id: pickerButton

        Layout.fillWidth: true
        Layout.preferredHeight: 36
        bgColor: Theme.palette.baseColor5
        contentColor: Theme.palette.directColor1
        text: root.collectibleName
        font.pixelSize: 13
        asset.name: root.collectibleImage

        onClicked: pickerClicked()
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 16
        Layout.rightMargin: 6
        Layout.topMargin: 8

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Specific amount")
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
        StatusSwitch { id: specificAmountSwitch }
    }

    StatusInput {
        id: amountInput

        Layout.fillWidth: true
        Layout.topMargin: 8
        visible: specificAmountSwitch.checked
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
