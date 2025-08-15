import QtQuick
import QtQuick.Controls

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import utils

/*!
   \qmltype CurrencyAmountInput
   \inherits StatusTextField
   \brief Provides a text input field that accepts a numeric value, with optional (currency) symbol (defaults to "USD").
          Utilizes a builtin DoubleValidator to validate the user's input.
          It accepts both the native decimal separator and optionally a period (`.`) for locales that don't use this.
   \inqmlmodule shared.controls 1.0

   Internally it uses FormattedDoubleProperty object that keeps track of the value.
  */
StatusTextField {
    id: root

    property alias value: internalProp.value // accepts double/float or string representation, rejects NaN
    readonly property bool valid: acceptableInput

    property int decimals: 2 // number of decimal places to display
    property string currencySymbol: "USD" // currency symbol, optional
    property double minValue: 0 // min value
    property double maxValue: Number.MAX_VALUE // max value

    property alias locale: internalProp.locale // locale code name (affects the validator and decimal point handler)
    readonly property string asLocaleString: {
        internalProp.value
        return root.valid ? internalProp.asLocaleString(root.decimals) : "NaN"
    }
    readonly property string asString: internalProp.asString // "C" locale string

    FormattedDoubleProperty {
        id: internalProp
        onValueChanged: {
            const oldPos = root.cursorPosition
            root.text = asLocaleString() // min number of decimals, strip zeroes
            root.cursorPosition = oldPos
        }
    }

    Keys.onPressed: (event) => {
                        // reject group (thousands) separator
                        if (event.text === Qt.locale(root.locale).groupSeparator) {
                            event.accepted = true
                        } else if (event.key === Qt.Key_Period) { // additionally accept dot (.) and convert it to the correct decimal point char
                            root.insert(root.cursorPosition, Qt.locale(root.locale).decimalPoint)
                            event.accepted = true
                        } else if (event.modifiers === Qt.NoModifier && event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
                            // reject typing non-numbers (can happen when the validator is in an intermediate state)
                            event.accepted = true
                        }
                    }

    Component.onCompleted: text = internalProp.asLocaleString(decimals)
    onTextEdited: value = text

    leftPadding: Theme.padding
    rightPadding: currencySymbol !== "" ?
                      currencySymbolText.width + currencySymbolText.anchors.leftMargin + currencySymbolText.anchors.rightMargin :
                      Theme.padding
    topPadding: 10
    bottomPadding: 10

    hoverEnabled: !readOnly
    inputMethodHints: Qt.ImhFormattedNumbersOnly

    validator: DoubleValidator {
        notation: DoubleValidator.StandardNotation
        decimals: root.decimals
        bottom: root.minValue
        top: root.maxValue
        locale: internalProp.locale
    }

    background: Rectangle {
        radius: Theme.radius
        color: Theme.palette.statusAppNavBar.backgroundColor
        border.width: 1
        border.color: {
            if (!root.valid && (root.focus || root.cursorVisible))
                return Theme.palette.dangerColor1
            if (root.cursorVisible || root.focus)
                return Theme.palette.primaryColor1
            if (root.hovered)
                return Theme.palette.primaryColor2
            return "transparent"
        }
        Behavior on border.color { ColorAnimation {} }
    }

    StatusBaseText {
        id: currencySymbolText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.padding
        anchors.rightMargin: Theme.padding
        color: Theme.palette.baseColor1
        text: root.currencySymbol
        visible: !!text
    }
}
