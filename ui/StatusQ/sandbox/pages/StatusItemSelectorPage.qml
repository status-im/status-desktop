import QtQuick 2.0
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
        popupItem: StatusDropdown {
            id: dropdown
            width: 200
            contentItem: ColumnLayout {
                spacing: 10
                StatusInput {
                    id: input
                    Layout.fillWidth: true
                }
                StatusButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Add element"
                    onClicked: {
                        selector.addItem(input.text, "qrc:/images/SNT.png", selector.itemsModel.count > 0 ? Utils.Operators.Or : Utils.Operators.None)
                        dropdown.close()
                    }
                }
            }
        }
    }

    StatusButton {
        Layout.alignment: Qt.AlignHCenter
        text: "Clear list"
        onClicked: { selector.itemsModel.clear() }
    }
}
