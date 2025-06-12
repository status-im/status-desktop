import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import QtModelsToolkit 1.0

Item {
    id: root

    ListModel {
        id: simpleSourceModel

        ListElement {
            name: "entry 1"
        }
        ListElement {
            name: "entry 2"
        }
        ListElement {
            name: "entry 3"
        }
        ListElement {
            name: "entry 4"
        }
        ListElement {
            name: "entry 5"
        }
        ListElement {
            name: "entry 6"
        }
        ListElement {
            name: "entry 7"
        }
        ListElement {
            name: "entry 8"
        }
    }

    MovableModel {
        id: movableModel

        sourceModel: simpleSourceModel
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 50

        ColumnLayout {
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true

            Label {
                text: "SOURCE MODEL"

                font.bold: true
                font.pixelSize: Theme.secondaryAdditionalTextSize
            }

            ListView {
                id: sourceListView

                spacing: 5

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: simpleSourceModel

                ScrollBar.vertical: ScrollBar {}

                delegate: RowLayout {
                    width: ListView.view.width

                    Label {
                        Layout.fillWidth: true

                        font.bold: true
                        text: model.name
                    }

                    Button {
                        text: "delete"

                        onClicked: simpleSourceModel.remove(model.index)
                    }

                    Button {
                        text: "alter"

                        onClicked: simpleSourceModel.setProperty(
                                       index, "name", simpleSourceModel.get(index).name + "_")
                    }

                    Button {
                        text: "⬆️"

                        onClicked: {
                            if (index !== 0)
                                simpleSourceModel.move(index, index - 1, 1)
                        }
                    }
                    Button {
                        text: "⬇️"

                        onClicked: {
                            if (index !== simpleSourceModel.count - 1)
                                simpleSourceModel.move(index, index + 1, 1)
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true

            Label {
                text: "MOVABLE MODEL (press to drag&drop)"

                font.bold: true
                font.pixelSize: Theme.secondaryAdditionalTextSize
            }

            ListView {
                id: transformedListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 5

                model: movableModel

                ScrollBar.vertical: ScrollBar {}

                delegate: StatusMouseArea {
                    id: dragArea

                    property bool held: false
                    readonly property int idx: model.index

                    anchors {
                        left: parent ? parent.left : undefined
                        right: parent ? parent.right : undefined
                    }
                    height: content.implicitHeight

                    drag.target: held ? content : undefined
                    drag.axis: Drag.YAxis

                    onPressAndHold: held = true
                    onReleased: held = false


                    RowLayout {
                        id: content

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        width: dragArea.width

                        Drag.active: dragArea.held
                        Drag.source: dragArea
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        states: State {
                            when: dragArea.held

                            ParentChange { target: content; parent: root }
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
                            text: model.name
                        }

                        Button {
                            text: "⬆️"
                            enabled: index > 0

                            onClicked: movableModel.move(index, index - 1)
                        }
                        Button {
                            text: "⬇️"
                            enabled: index < transformedListView.count - 1

                            onClicked: movableModel.move(index, index + 1)
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
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.margins: 10

        Button {
            text: "append to source model"

            onClicked: simpleSourceModel.append({ name: "X" })
        }

        Button {
            text: "desynchronize"

            onClicked: {
                movableModel.desyncOrder()
            }
        }

        Button {
            text: "synchronize"

            onClicked: {
                movableModel.syncOrder()
            }
        }

        Label {
            text: "Synchronized: " + movableModel.synced
        }
    }
}

// category: Models
