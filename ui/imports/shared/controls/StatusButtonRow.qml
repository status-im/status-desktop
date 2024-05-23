import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

Control {
    id: root

    property var model: [0.1, 0.5, 1]
    property double defaultValue: 0.5
    property string symbolValue: " %"

    property alias currentValue: d.currentValue

    readonly property bool valid: d.currentValue && (d.customInputFocused ? customLoader.item.valid : true)

    function reset() {
        customLoader.sourceComponent = customButtonComponent
        d.currentValue = root.defaultValue
    }

    Component.onCompleted: {
        if (currentValue && !root.model.includes(currentValue))
            d.activateCustomInput()
    }

    QtObject {
        id: d

        property double currentValue: root.defaultValue

        readonly property bool customInputFocused: customLoader.sourceComponent === customInputComponent && customLoader.item.focus

        function activateCustomInput() {
            customLoader.sourceComponent = customInputComponent
            customLoader.item.forceActiveFocus()
        }
    }

    background: null
    contentItem: RowLayout {
        spacing: Style.current.halfPadding

        Repeater {
            objectName: "buttonsRepeater"
            model: root.model
            delegate: StatusButton {
                readonly property double value: modelData
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                type: checked ? StatusBaseButton.Type.Primary : StatusBaseButton.Type.Normal
                checkable: true
                checked: value === d.currentValue && !d.customInputFocused
                text: "%L1%2".arg(modelData).arg(root.symbolValue)
                onClicked: d.currentValue = value
            }
        }
        Loader {
            id: customLoader
            objectName: "customLoader"
            Layout.minimumWidth: 130
            Layout.fillWidth: true
            sourceComponent: customButtonComponent
        }
    }

    Component {
        id: customButtonComponent
        StatusButton {
            objectName: "customButton"
            text: qsTr("Custom")
            onClicked: d.activateCustomInput()
        }
    }
    Component {
        id: customInputComponent
        CurrencyAmountInput {
            objectName: "customInput"
            minValue: 0.01
            currencySymbol: root.symbolValue
            focus: value === d.currentValue
            onValueChanged: d.currentValue = value
            onFocusChanged: {
                if (focus && valid)
                    d.currentValue = value
                else if (!valid)
                    clear()
            }
            Component.onCompleted: {
                if (d.currentValue && d.currentValue !== root.defaultValue && !root.model.includes(d.currentValue))
                    value = d.currentValue
            }
        }
    }
}
