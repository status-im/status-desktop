import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Input {
    id: root

    property int maximumLength: 10
    property var locale: Qt.locale()

    readonly property alias amount: d.amount
    readonly property bool valid: validationError.length === 0
    property bool allowDecimals: true

    validationErrorTopMargin: 8
    fontPixelSize: 13
    customHeight: 36
    placeholderText: locale.zeroDigit

    textField.rightPadding: labelText.implicitWidth + labelText.anchors.rightMargin
                            + textField.leftPadding

    function setAmount(amount) {
        root.text = LocaleUtils.numberToLocaleString(amount)
    }

    QtObject {
        id: d

        property real amount: 0
    }

    validator: DoubleValidator {
        id: doubleValidator

        decimals: root.allowDecimals ? 100 : 0
        bottom: 0
        notation: DoubleValidator.StandardNotation
        locale: root.locale.name
    }

    onTextChanged: {
        if (!allowDecimals)
            text = text.replace(root.locale.decimalPoint, "")

        if(text.length === 0) {
            d.amount = 0
            root.validationError = ""
            return
        }

        if (text.length > root.maximumLength) {
            root.validationError = qsTr("The maximum number of characters is %1").arg(root.maximumLength)
            return
        }

        try {
            d.amount = LocaleUtils.numberFromLocaleString(text) || 0
            root.validationError = ""
        } catch (err) {
           root.validationError = qsTr("Invalid amount format")
        }
    }

    StatusBaseText {
        id: labelText

        parent: root.textField

        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Amount")
        color: Theme.palette.baseColor1
        font.pixelSize: 13
    }
}
