import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

/*!
   \qmltype CurrencyAmountInput
   \inherits TextField
   \brief Provides a text input field that accepts a numeric value, with optional currency symbol ("USD").
          Utilizes a builtin DoubleValidator to validate the user's input.
          It accepts both the native decimal separator and optionally a period (`.`) for locales that don't use this.
   \inqmlmodule shared.controls 1.0

   Internally it uses FormattedDoubleProperty object that keeps track of the value.
  */
TextField {
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
                        // additionally accept dot (.) and convert it to the correct decimal point char
                        if (event.key === Qt.Key_Period) {
                            root.insert(root.cursorPosition, Qt.locale(root.locale).decimalPoint)
                            event.accepted = true
                        } else if (event.modifiers === Qt.NoModifier && event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
                            // reject typing non-numbers (can happen when the validator is in an intermediate state)
                            event.accepted = true
                        }
                    }

    Component.onCompleted: text = internalProp.asLocaleString(decimals)
    onTextEdited: value = text

    font.family: Style.current.baseFont.name
    font.pixelSize: Style.current.primaryTextFontSize

    leftPadding: Style.current.padding
    rightPadding: currencySymbol !== "" ?
                      currencySymbolText.width + currencySymbolText.anchors.leftMargin + currencySymbolText.anchors.rightMargin :
                      Style.current.padding
    topPadding: 10
    bottomPadding: 10

    opacity: enabled ? 1 : 0.3
    color: readOnly ? Theme.palette.baseColor1 : Theme.palette.directColor1
    selectionColor: Theme.palette.primaryColor2
    selectedTextColor: Theme.palette.directColor1
    placeholderTextColor: Theme.palette.baseColor1

    hoverEnabled: !readOnly
    selectByMouse: true
    inputMethodHints: Qt.ImhFormattedNumbersOnly

    validator: DoubleValidator {
        notation: DoubleValidator.StandardNotation
        decimals: root.decimals
        bottom: root.minValue
        top: root.maxValue
        locale: internalProp.locale
    }

    background: Rectangle {
        radius: Style.current.radius
        color: Theme.palette.statusAppNavBar.backgroundColor
        border.width: root.cursorVisible || root.hovered || !root.valid ? 1 : 0
        border.color: {
            if (!root.valid)
                return Theme.palette.dangerColor1
            if (root.cursorVisible)
                return Theme.palette.primaryColor1
            if (root.hovered)
                return Theme.palette.primaryColor2
            return "transparent"
        }
        Behavior on border.color { ColorAnimation {} }
    }

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }

    StatusBaseText {
        id: currencySymbolText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        color: Theme.palette.baseColor1
        text: root.currencySymbol
        visible: !!text
    }
}
