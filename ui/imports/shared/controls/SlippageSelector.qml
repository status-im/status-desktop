import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

Control {
    id: root

    property double value: d.defaultValue
    readonly property double defaultValue: d.defaultValue
    readonly property bool valid: customInput.activeFocus && customInput.valid
                                  || buttons.value !== null
    readonly property bool isEdited: root.value !== d.defaultValue

    function reset() {
        value = d.defaultValue
    }

    onValueChanged: {
        if (d.internalUpdate)
            return false

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
    contentItem: RowLayout {
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
            maxValue: 100.0
            currencySymbol: d.customSymbol
            onValueChanged: d.update(value)
            onFocusChanged: {
                if (focus && valid)
                    d.update(value)
                else if (!valid)
                    clear()
            }
        }
    }
}
