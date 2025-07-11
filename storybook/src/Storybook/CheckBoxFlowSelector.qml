import QtQuick
import QtQuick.Controls

Flow {
    id: root

    property alias model: repeater.model

    property var selection: []
    property bool initialSelection
    property bool exclusive: false

    ButtonGroup {
        id: checkboxGroup
        exclusive: root.exclusive
    }

    Repeater {
        id: repeater

        function update() {
            const selection = []

            for (let i = 0; i < repeater.count; i++) {
                const item = repeater.itemAt(i)
                if (!!item && item.checked)
                    selection.push(item.text)
            }

            root.selection = selection
        }

        CheckBox {
            text: modelData
            checked: root.initialSelection
            onToggled: repeater.update()
            ButtonGroup.group: checkboxGroup
        }

        onItemAdded: update()
    }
}
