import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Core.Theme

import utils

ColumnLayout {

    StatusFlowSelector {
        Layout.fillWidth: true
        Layout.margins: 100

        icon: Theme.png("tokens/SNT")
        title: "Item Selector Title"

        placeholderText: "Example: Empty items"

        Repeater {
            id: repeater

            model: ListModel {
                id: listModel
            }

            property int counter: 0

            delegate: StatusListItemTag {
                title: `tag ${model.name}`

                onClicked: listModel.remove(index)
            }
        }

        placeholderItem.visible: listModel.count === 0

        addButton.onClicked: {
            listModel.append({ name: `item ${repeater.counter++}` })
        }
    }

    Button {
        Layout.bottomMargin: 10
        Layout.alignment: Qt.AlignHCenter

        text: "Clear list"
        onClicked: listModel.clear()
    }
}

// category: Components
