import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

Control {
    id: root

    property double value: d.defaultValue
    readonly property double defaultValue: d.defaultValue
    readonly property bool valid: (customInput.activeFocus && customInput.valid) || buttons.value !== null
    readonly property bool isEdited: root.value !== d.defaultValue

    property double valueTooHighThreshold: 5

    function reset() {
        value = d.defaultValue
        customInput.focus = false
        customButton.visible = true
    }

    onValueChanged: {
        if (d.internalUpdate)
            return

        const custom = !d.values.includes(value)

        if (custom) {
            customButton.visible = false
            customInput.value = value
            customInput.forceActiveFocus()
        } else {
            customButton.visible = true
        }
    }

    Component.onCompleted: {
        buttons.model.append(d.values.map((i) => ({ text: "%L1 %2".arg(i).arg(d.customSymbol), value: i })))
        valueChanged()
    }

    QtObject {
        id: d

        readonly property string customSymbol: "%"
        readonly property var values: [0.1, 0.5, 1]
        readonly property double defaultValue: 0.5
        property bool internalUpdate: false

        function update(value) {
            internalUpdate = true
            root.value = value
            internalUpdate = false
        }
    }

    background: null
    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            spacing: buttons.spacing

            StatusButtonRow {
                id: buttons
                model: ListModel {}

                Binding on value {
                    value: customInput.activeFocus ? null : root.value
                }

                onValueChanged: {
                    if (value === null)
                        return

                    d.update(value)
                }
                onButtonClicked: customButton.visible = true
            }

            StatusButton {
                id: customButton
                objectName: "customButton"

                Layout.minimumWidth: 130

                text: qsTr("Custom")
                onClicked: {
                    visible = false
                    customInput.clear()
                    customInput.forceActiveFocus()
                }
            }

            CurrencyAmountInput {
                id: customInput
                objectName: "customInput"

                Layout.minimumWidth: customButton.Layout.minimumWidth

                visible: !customButton.visible
                minValue: 0.01
                maxValue: 99.99
                maximumLength: 6 // 3 integral + separator + 2 decimals (e.g. "999.99")
                currencySymbol: d.customSymbol
                onValueChanged: d.update(value)
            }
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignRight
            visible: customInput.visible && !customInput.valid
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            text: {
                if (customInput.length === 0)
                    return qsTr("Enter a slippage value")

                if (customInput.value === 0)
                    return qsTr("Slippage should be more than 0")

                return qsTr("Invalid value")
            }
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignRight
            visible: customInput.visible && customInput.valid && customInput.value > root.valueTooHighThreshold
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.warningColor1
            text: qsTr("Slippage may be higher than necessary")
        }
    }
}
