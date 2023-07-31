import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

ColumnLayout {
    spacing: 20

    StatusItemSelector {
        id: selector

        icon: Style.png("tokens/SNT")
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
                            imageSource: Style.png("tokens/SNT"),
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
