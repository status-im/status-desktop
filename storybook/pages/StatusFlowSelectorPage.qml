import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import utils 1.0


ColumnLayout {
    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        StatusFlowSelector {
            anchors.centerIn: parent

            icon: Style.png("tokens/SNT")
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
    }

    Button {
        Layout.bottomMargin: 10
        Layout.alignment: Qt.AlignHCenter

        text: "Clear list"
        onClicked: listModel.clear()
    }
}

// category: Components
