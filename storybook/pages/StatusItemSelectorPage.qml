import QtQuick
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Utils
import StatusQ.Core.Theme

import utils

ColumnLayout {
    spacing: 20

    StatusItemSelector {
        id: selector

        Layout.fillWidth: true
        Layout.margins: 50

        icon: Theme.png("tokens/SNT")
        title: "Item Selector Title"

        placeholderText: "Example: Empty items"

        model: ListModel {
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
                            imageSource: Theme.png("tokens/SNT"),
                            isIcon: false,
                            operator: model.count > 0 ? OperatorsUtils.Operators.Or
                                                      : OperatorsUtils.Operators.None
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
        onClicked: model.clear()
    }
}

// category: Components
