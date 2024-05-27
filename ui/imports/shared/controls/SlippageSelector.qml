import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

Control {
    id: root

    property double value: 0.5
    readonly property bool valid: customInput.visible && customInput.valid
                                  || buttons.value !== null

    onValueChanged: {
        if (d.internalUpdate)
            return false

        const custom = !d.values.includes(value)

        if (custom) {
            customButton.visible = false
            customInput.value = value
        } else {
            customButton.visible = true
        }
    }

    Component.onCompleted: {
        buttons.model.append(d.values.map(i => ({ text: "%L1 %".arg(i), value: i })))
        valueChanged()
    }

    QtObject {
        id: d

        readonly property var values: [0.1, 0.5, 1]
        property bool internalUpdate: false

        function update(value) {
            internalUpdate = true
            root.value = value
            internalUpdate = false
        }
    }

    contentItem: RowLayout {
        spacing: buttons.spacing

        StatusButtonRow {
            id: buttons

            model: ListModel {}

            Binding on value {
                value: customInput.visible ? null : root.value
            }

            onValueChanged: {
                if (value === null)
                    return

                d.update(value)
                customButton.visible = true
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
            currencySymbol: "%"
            onValueChanged: d.update(value)
        }
    }
}
