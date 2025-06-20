import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    ListModel {
        id: simpleSourceModel

        ListElement {
            name: "entry 0"
            position: 0
        }
        ListElement {
            name: "entry 1"
            position: 1
        }
        ListElement {
            name: "entry 2"
            position: 2
        }
        ListElement {
            name: "entry 3"
            position: 3
        }
        ListElement {
            name: "entry 4"
            position: 7
        }
        ListElement {
            name: "entry 5"
            position: 6
        }
        ListElement {
            name: "entry 6"
            position: 5
        }
        ListElement {
            name: "entry 7"
            position: 4
        }
    }

    SortFilterProxyModel {
        id: sorted

        sorters: RoleSorter {
            roleName: sortByPositionRadioButton.checked ? "position" : "name"
            sortOrder: descendingCheckBox.checked ? Qt.DescendingOrder
                                                  : Qt.AscendingOrder
        }

        sourceModel: simpleSourceModel
    }

    MovableModel {
        id: movableModel

        sourceModel: sorted
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                id: sourceColumn

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 20
                spacing: 20

                width: parent.width / 3

                Label {
                    text: "SOURCE MODEL"

                    font.bold: true
                    font.pixelSize: Theme.secondaryAdditionalTextSize
                }

                ListView {
                    id: sourceListView

                    spacing: 5
                    clip: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: simpleSourceModel

                    ScrollBar.vertical: ScrollBar {}

                    delegate: Item {
                        id: sourceDelegateRoot

                        anchors {
                            left: parent ? parent.left : undefined
                            right: parent ? parent.right : undefined
                        }

                        height: sourceContent.implicitHeight

                        RowLayout {
                            id: sourceContent

                            Rectangle {
                                color: "lightgray"
                                Layout.fillHeight: true
                                Layout.preferredWidth: 40

                                Label {
                                    anchors.centerIn: parent
                                    text: "↕️"
                                }

                                StatusMouseArea {
                                    id: sourceDragArea

                                    property bool held: false
                                    readonly property int idx: model.index

                                    anchors.fill: parent

                                    drag.target: held ? sourceContent : undefined
                                    drag.axis: Drag.YAxis

                                    onPressed: held = true
                                    onReleased: held = false
                                }
                            }

                            width: sourceDelegateRoot.width

                            Drag.active: sourceDragArea.held
                            Drag.source: sourceDragArea
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            states: State {
                                when: sourceDragArea.held

                                ParentChange {
                                    target: sourceContent
                                    parent: root
                                }

                                AnchorChanges {
                                    target: sourceContent
                                    anchors {
                                        horizontalCenter: undefined
                                        verticalCenter: undefined
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true

                                font.bold: true
                                text: model.name + ", position: " + model.position
                            }

                            RoundButton {
                                text: "❌"

                                onClicked: simpleSourceModel.remove(model.index)
                            }

                            RoundButton {
                                text: "✎"

                                onClicked: simpleSourceModel.setProperty(
                                               index, "name", simpleSourceModel.get(index).name + "_")
                            }
                        }

                        DropArea {
                            anchors { fill: parent; margins: 10 }

                            onEntered: {
                                const from = drag.source.idx
                                const to = sourceDragArea.idx

                                if (from === to)
                                    return

                                simpleSourceModel.move(from, to, 1)
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: sfpmColumn

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: sourceColumn.right
                anchors.margins: 20

                spacing: 20

                width: parent.width / 3

                Label {
                    text: "SFPM MODEL"

                    font.bold: true
                    font.pixelSize: Theme.secondaryAdditionalTextSize
                }

                ListView {
                    id: sfpmListView

                    spacing: 5
                    clip: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: sorted

                    ScrollBar.vertical: ScrollBar {}

                    delegate: RowLayout {
                        width: ListView.view.width

                        Label {
                            Layout.fillWidth: true

                            font.bold: true
                            text: model.name + ", position: " + model.position
                        }

                        // to keep the same delegate height as in other list views
                        RoundButton {
                            enabled: false
                            opacity: 0
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: sfpmColumn.right
                anchors.right: parent.right
                anchors.margins: 20

                spacing: 20

                Label {
                    text: "MOVABLE MODEL"
                    font.bold: true
                    font.pixelSize: Theme.secondaryAdditionalTextSize
                }

                ListView {
                    id: transformedListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    spacing: 5
                    clip: true

                    model: movableModel

                    ScrollBar.vertical: ScrollBar {}

                    delegate: Item {
                        id: delegateRoot

                        anchors {
                            left: parent ? parent.left : undefined
                            right: parent ? parent.right : undefined
                        }

                        height: content.implicitHeight

                        RowLayout {
                            id: content

                            Rectangle {

                                color: "lightgray"
                                Layout.fillHeight: true
                                Layout.preferredWidth: 40

                                Label {
                                    anchors.centerIn: parent
                                    text: "↕️"
                                }

                                StatusMouseArea {
                                    id: dragArea

                                    property bool held: false
                                    readonly property int idx: model.index

                                    anchors.fill: parent

                                    drag.target: held ? content : undefined
                                    drag.axis: Drag.YAxis

                                    onPressed: held = true
                                    onReleased: held = false
                                }
                            }

                            width: delegateRoot.width

                            Drag.active: dragArea.held
                            Drag.source: dragArea
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            states: State {
                                when: dragArea.held

                                ParentChange {
                                    target: content
                                    parent: root
                                }

                                AnchorChanges {
                                    target: content
                                    anchors {
                                        horizontalCenter: undefined
                                        verticalCenter: undefined
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true

                                font.bold: true
                                text: model.name + ", position: " + model.position
                            }

                            RoundButton {
                                text: "⬆️"
                                enabled: index > 0

                                onClicked: movableModel.move(index, 0)
                            }
                            RoundButton {
                                text: "⬇️"
                                enabled: index < transformedListView.count - 1

                                onClicked: movableModel.move(
                                               index, transformedListView.count - 1)
                            }
                        }

                        DropArea {
                            anchors { fill: parent; margins: 10 }

                            onEntered: {
                                const from = drag.source.idx
                                const to = dragArea.idx

                                if (from === to)
                                    return

                                movableModel.move(from, to)
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                color: "gray"
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: sourceColumn.right
                anchors.leftMargin: 10
            }

            Rectangle {
                width: 1
                color: "gray"
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: sfpmColumn.right
                anchors.leftMargin: 10
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter

            text: "SAVE ORDER"
            font.pixelSize: Theme.fontSize30

            onClicked: {
                const count = simpleSourceModel.count
                const newOrder = movableModel.order()
                const newOrderInverted = []
                const sourceIndexes = []

                for (let i = 0; i < count; i++)
                    newOrderInverted[newOrder[i]] = i

                for (let j = 0; j < count; j++)
                    sourceIndexes.push(sorted.mapToSource(j))

                for (let k = 0; k < count; k++)
                    simpleSourceModel.setProperty(sourceIndexes[k], "position",
                                                  newOrderInverted[k])
            }
        }

        RowLayout {
            Layout.fillHeight: false

            RadioButton {
                text: "Sort by name"
            }

            RadioButton {
                id: sortByPositionRadioButton

                text: "Sort by position"
                checked: true
            }

            CheckBox {
                id: descendingCheckBox
                text: "descending"
            }
        }

        RowLayout {
            Layout.fillHeight: false

            Button {
                text: "append to source model"

                onClicked: simpleSourceModel.append({ name: "X" })
            }

            Button {
                text: "desynchronize"

                onClicked: movableModel.desyncOrder()
            }

            Button {
                text: "synchronize"

                onClicked: movableModel.syncOrder()
            }

            Label {
                text: `Synchronized: <b>${movableModel.synced}</b>`
            }
        }
    }
}

// category: Models
