import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1

import utils 1.0

Flow {
    id: root

    property alias model: repeater.model

    property var selection: []
    property bool initialSelection

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
        }

        onItemAdded: update()
    }
}
