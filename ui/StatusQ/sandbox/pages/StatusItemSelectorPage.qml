import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    spacing: 20

    StatusItemSelector {
        id: selector
        icon: "qrc:/images/SNT.png"
        iconSize: 24
        title: "Item Selector Title"
        defaultItemText: "Example: Empty items"

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
                            operator: model.count > 0 ? OperatorsUtils.Operators.Or : OperatorsUtils.Operators.None
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

    StatusNetworkSelector {
        id: networkSelector

        // title: "Network Selector Title"
        defaultItemText: "Add networks"
        defaultItemImageSource: "add"
        // asset.color: Theme.palette.primaryColor1
        radius: 0
        closeButtonVisible: true
        // color: "transparent"
        // color: "yellow"

        addButton.onClicked: {
            console.log("on add button clicked")
            itemsModel.append({
                text: "Tetxt"
            })
        }

        onItemClicked: {
            console.log("onItemClicked:", index)
            if (index === 0 && defaultItem.visible)
                itemsModel.append({
                    text: "First Text"
                })

        }

        onItemButtonClicked: {
            console.log("onItemButtonClicked:", index)
            itemsModel.remove(index)
        }
        // defaultItem.titleText.color: Theme.palette.primaryColor1



        // itemsModel: ListModel {
        //     id: model
        // }
    }

    StatusButton {
        Layout.alignment: Qt.AlignHCenter
        text: "Clear list"
        onClicked: { selector.itemsModel.clear() }
    }
}
