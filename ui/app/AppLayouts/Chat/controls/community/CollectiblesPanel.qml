import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property alias specificAmount: specificAmountSwitch.checked
    property alias collectibleName: pickerButton.text
    property url collectibleImage

    property alias amountText: amountInput.text
    property alias amount: amountInput.amount
    readonly property bool amountValid: amountInput.valid && amountInput.text.length > 0

    signal pickerClicked

    function setAmount(amount) {
        amountInput.setAmount(amount)
    }

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

    AmountInput {
        id: amountInput

        visible: specificAmountSwitch.checked

        Layout.fillWidth: true
        Layout.topMargin: 8

        allowDecimals: false
    }
}
