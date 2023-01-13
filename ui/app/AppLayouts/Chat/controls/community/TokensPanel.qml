import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property alias tokenName: pickerButton.text
    property url tokenImage
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
        font.pixelSize: 13
        asset.name: root.tokenImage

        onClicked: pickerClicked()
    }

    AmountInput {
        id: amountInput

        Layout.fillWidth: true
        Layout.topMargin: 8
    }
}
