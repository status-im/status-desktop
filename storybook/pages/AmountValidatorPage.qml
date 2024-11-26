import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Validators 0.1

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent

        TextField {
            id: textField

            Layout.alignment: Qt.AlignHCenter

            validator: AmountValidator {
                decimalPoint: buttonGroup.checkedButton.decimalPoint

                maxIntegralDigits: maxIntegralDigitsSpinBox.value
                maxDecimalDigits: maxDecimalDigitsSpinBox.value
                maxDigits: maxTotalDigitsSpinBox.value
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: `acceptableInput: ${textField.acceptableInput}`
        }

        ButtonGroup {
            id: buttonGroup

            buttons: radioButtonsRow.children
        }

        RowLayout {
            id: radioButtonsRow

            Layout.alignment: Qt.AlignHCenter

            RadioButton {
                checked: true
                text: "period (.)"

                readonly property string decimalPoint: "."
            }

            RadioButton {
                text: "comma (,)"

                readonly property string decimalPoint: ","
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: "Max number of integral digits:"
            }

            SpinBox {
                id: maxIntegralDigitsSpinBox
                value:  10
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: "Max number of decimal digits:"
            }

            SpinBox {
                id: maxDecimalDigitsSpinBox

                value: 5
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: "Max total digits:"
            }

            SpinBox {
                id: maxTotalDigitsSpinBox

                value: maxIntegralDigitsSpinBox.value + maxDecimalDigitsSpinBox.value
            }
        }
    }
}

// category: Validators
