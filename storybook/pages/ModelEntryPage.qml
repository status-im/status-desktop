import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

Control {
    id: root

    UsersModel {
        id: usersModel
    }

    ModelEntry {
        id: itemData
        sourceModel: usersModel
        key: "pubKey"
        value: pubKeySelector.currentText
        
        onItemChanged: signalsModel.append({        signal: "Item changed",     value: "", row: itemData.row, item: itemData.item, roles: JSON.stringify(itemData.roles), available: itemData.available})
        onRowChanged: signalsModel.append({         signal: "Row changed",      value: "", row: itemData.row, item: itemData.item, roles: JSON.stringify(itemData.roles), available: itemData.available})
        onAvailableChanged: signalsModel.append({   signal: "Available changed",value: "", row: itemData.row, item: itemData.item, roles: JSON.stringify(itemData.roles), available: itemData.available})
        onRolesChanged: signalsModel.append({       signal: "Roles changed",    value: "", row: itemData.row, item: itemData.item, roles: JSON.stringify(itemData.roles), available: itemData.available})
    }

    Instantiator {
        model: itemData.roles
        delegate: QtObject {
            property var connection: {
                return Qt.createQmlObject(`
                    import QtQml 2.15
                    Connections {
                        target: itemData.item
                        function on${modelData.charAt(0).toUpperCase() + modelData.slice(1)}Changed() {
                            signalsModel.append({ signal: "${modelData} changed", value: itemData.item.${modelData}, row: itemData.row, item: itemData.item, roles: JSON.stringify(itemData.roles), available: itemData.available})
                        }
                    }
                `, this, "dynamicConnectionOn${modelData}")
            }
        }
    }

    ListModel {
        id: signalsModel
    }
    
    contentItem: ColumnLayout {
        anchors.fill: parent
        Pane {
            Layout.fillWidth: true
            background: Rectangle {
                border.width: 1
                border.color: "lightgray"
            }
            contentItem: ColumnLayout {
                Label {
                    text: "User with pubKey " + itemData.value
                    font.bold: true
                }
                Label {
                    text: "Data available: " + itemData.available
                    font.bold: true
                }
                Label {
                    text: "Keys: " + itemData.roles
                    font.bold: true
                }
                Label {
                    text: "Item removed from model: " + itemData.itemRemovedFromModel
                    font.bold: true
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            active: itemData.available
            sourceComponent: Pane {
                background: Rectangle {
                    border.width: 1
                    border.color: "lightgray"
                }
                contentItem: ColumnLayout {
                    Repeater {
                        model: itemData.roles
                        delegate: Label {
                            text: modelData + ": " + itemData.item[modelData]
                        }
                    }
                }
            }
        }

        GenericListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: usersModel
            insetComponent: RowLayout {
                Button {
                    height: 20
                    font.pixelSize: Theme.fontSize11
                    text: "remove"
                    highlighted: model.index === itemData.row

                    onClicked: {
                        usersModel.remove(model.index)
                    }
                }
                Button {
                    height: 20
                    font.pixelSize: Theme.fontSize11
                    text: "edit"
                    highlighted: model.index === itemData.row

                    onClicked: {
                        menu.row = model.index
                        menu.popup()
                    }
                }
            }
        }
        GenericListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: showSignals.checked && !!count
            model: signalsModel
            header:  Label {
                width: parent.width
                text: "Item Signals"
                font.bold: true
                font.pixelSize: Theme.fontSize16
                bottomPadding: 20
                Button {
                    anchors.right: parent.right
                    text: "clear"
                    onClicked: signalsModel.clear()
                }
            }
        }
        Pane {
            contentItem: RowLayout {
                ComboBox {
                    Layout.preferredWidth: 250
                    id: pubKeySelector
                    model: [...ModelUtils.modelToFlatArray(usersModel, "pubKey"), "none"]
                }
                CheckBox {
                    text: "Cache item on removal"
                    checked: itemData.cacheOnRemoval
                    onCheckedChanged: {
                        itemData.cacheOnRemoval = checked
                    }
                }
                CheckBox {
                    id: showSignals
                    text: "Show signals"
                }
            }
        }
    }

    Menu {
        id: menu

        property int row: -1

        readonly property var modelItem: usersModel.get(row)

        contentItem: ColumnLayout {
            Label {
                text: "Edit user"
                font.bold: true
            }
            TextField {
                id: pubKeyField
                placeholderText: "pubKey"
                enabled: !!menu.modelItem
                text: !!menu.modelItem ? menu.modelItem.pubKey : ""
                onAccepted: usersModel.setProperty(menu.row, "pubKey", pubKeyField.text)
            }
            TextField {
                id: displayNameField
                placeholderText: "displayName"
                enabled: !!menu.modelItem
                text: !!menu.modelItem ? menu.modelItem.displayName : ""
                onAccepted: usersModel.setProperty(menu.row, "displayName", displayNameField.text)
            }
            TextField {
                id: ensNameField
                placeholderText: "ensName"
                enabled: !!menu.modelItem
                text: !!menu.modelItem ? menu.modelItem.ensName : ""
                onAccepted: usersModel.setProperty(menu.row, "ensName", ensNameField.text)
            }
        }
    }
}

// category: Models
