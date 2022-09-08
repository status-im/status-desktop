import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

ColumnLayout {
    spacing: 20
    StatusItemSelector {
        id: selector
        icon: "qrc:/images/SNT.png"
        iconSize: 24
        title: "Item Selector Title"
        defaultItemText: "Example: Empty items"
        andOperatorText: "and"
        orOperatorText: "or"

        itemsModel: ListModel {
            id: model
        }

        StatusDropdown {
            id: dropdown

            parent: selector.addButton
            width: 200
            contentItem: ColumnLayout {
                spacing: 10
                StatusInput {
                    id: input
                    text: "Sample"
                    Layout.fillWidth: true
                }
                StatusButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Add element"
                    onClicked: {
                        model.append({
                            text: input.text,
                            imageSource: "qrc:/images/SNT.png",
                            operator: model.count > 0 ? Utils.Operators.Or : Utils.Operators.None
                        })

                        dropdown.close()
                    }
                }
            }
        }

        addButton.onClicked: {
            dropdown.x = mouse.x
            dropdown.y = mouse.y
            dropdown.open()
        }
    }

    StatusButton {
        Layout.alignment: Qt.AlignHCenter
        text: "Clear list"
        onClicked: { selector.itemsModel.clear() }
    }
}
