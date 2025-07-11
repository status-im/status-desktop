import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Controls
import StatusQ.Components

import QtModelsToolkit

Item {
    id: root
    ListModel {
        id: listModel
        Component.onCompleted: {
            for (var i = 1; i < 1000; ++i) {
                listModel.append({
                    name: "Item " + i,
                    key: i
                })
            }
        }
    }

    ListModel {
        id: listModel2
        Component.onCompleted: {
            for (var i = 10; i < 50; ++i) {
                listModel2.append({
                    name: "Item " + i,
                    key: i
                })
            }
        }
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        ColumnLayout {
            Layout.maximumWidth: root.width / 2
            Layout.fillHeight: true
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: listModel
                clip: true
                delegate: DropArea {
                    height: draggableDelegate.implicitHeight
                    width: draggableDelegate.implicitWidth
                    onEntered: function(drag) {
                        const from = drag.source.visualIndex
                        const to = draggableDelegate.visualIndex
                        if (to === from)
                            return
                        listModel.move(from, to, 1)
                        drag.accept()
                    }
                    StatusDraggableListItem {
                        id: draggableDelegate
                        implicitWidth: 300
                        dragParent: root
                        visualIndex: index
                        draggable: listView.count > 1
                        text: name
                        secondaryTitle: "Key: " + key
                        onClicked: {
                            listModel.setProperty(index, "name", listModel.get(index).name + "!")
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                RowLayout{
                    Button {
                        text: "Insert at"
                        onClicked: {
                            listModel.insert(parseInt(insertIndex.text),{
                                name: "Item " + (listModel.count + 1),
                                key: listModel.count + 1
                            })
                        }
                    }
                    TextField {
                        id: insertIndex
                        text: "0"
                        cursorVisible: false
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }
                RowLayout{
                    Button {
                        text: "Remove at"
                        onClicked: {
                            listModel.remove(parseInt(removeIndex.text), 1)
                        }
                    }
                    TextField {
                        id: removeIndex
                        text: "0"
                        cursorVisible: false
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Label {
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillWidth: true
                text: writableProxyModel.dirty ? "Dirty" : "Clean"
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: writableProxyModel.dirty ? "red" : "green"
                    border.width: 2
                }
            }
            ListView {
                id: listViewWritable
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                clip: true
                implicitWidth: 300
                model: WritableProxyModel {
                    id: writableProxyModel
                    sourceModel: listModel
                }
                delegate: StatusDraggableListItem {
                    id: draggableDelegate
                    implicitWidth: 300
                    dragParent: root
                    visualIndex: index
                    draggable: listView.count > 1
                    text: model.name
                    secondaryTitle: "Key: " + model.key
                    onClicked: {
                        model.name = model.name + "!"
                    }
                }
            }

            RowLayout{
                Button {
                    text: "Insert at"
                    onClicked: {
                        writableProxyModel.insert(parseInt(insertWritableIndex.text), {
                            name: "Item " + (writableProxyModel.rowCount() + 1),
                            key: writableProxyModel.rowCount() + 1
                        })
                    }
                }
                TextField {
                    id: insertWritableIndex
                    text: "0"
                    cursorVisible: false
                    inputMethodHints: Qt.ImhDigitsOnly
                }
            }
            RowLayout{
                Button {
                    text: "Append"
                    onClicked: {
                        writableProxyModel.append({
                            name: "Item " + (writableProxyModel.rowCount() + 1),
                            key: writableProxyModel.rowCount() + 1
                        })
                    }
                }
            }
            RowLayout{
                Button {
                    text: "Remove from"
                    onClicked: {
                        writableProxyModel.remove(parseInt(removeWritableIndex.text))
                    }
                }
                TextField {
                    id: removeWritableIndex
                    text: "0"
                    cursorVisible: false
                    inputMethodHints: Qt.ImhDigitsOnly
                }
            }
            RowLayout {
                Button {
                    text: "Swap models"
                    onClicked: {
                        if (writableProxyModel.sourceModel === listModel) {
                            writableProxyModel.sourceModel = listModel2
                        } else {
                            writableProxyModel.sourceModel = listModel
                        }
                    }
                }
                Button {
                    text: "Revert"
                    onClicked: {
                        writableProxyModel.revert()
                    }
                }
            }
        }
    }
}

// category: Models
