import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils

import Storybook

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property int headerSize: 40

    function fillModel(model, count) {
        const content = []

        for (let i = 0; i < count; i++)
            content.push({})

        model.clear()
        model.append(content)
    }

    function adjustModel(model, newCount) {
        const countDiff = newCount - model.count
        const randPos = () => Math.floor(Math.random() * model.count)

        if (countDiff > 0) {
            for (let i = 0; i < countDiff; i++)
                model.insert(randPos(), {})
        } else {
            for (let i = 0; i < -countDiff; i++)
                model.remove(randPos())
        }
    }

    ListModel {
        id: firstModel

        Component.onCompleted: fillModel(this, firstSlider.value)
    }

    ListModel {
        id: secondModel

        Component.onCompleted: fillModel(this, secondSlider.value)
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            id: frame

            anchors.centerIn: parent

            width: Math.round(parent.width / 2)
            height: Math.round(parent.height / 2)
            border.width: 1
            color: "transparent"

            DoubleFlickable {
                id: doubleFlickable

                anchors.fill: parent
                clip: clipCheckBox.checked
                z: -1

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }

                flickable1: GridView {
                    width: frame.width
                    interactive: false
                    model: firstModel

                    cellWidth: 120
                    cellHeight: 30

                    header: Rectangle {
                        height: root.headerSize
                        width: GridView.view.width

                        color: "orange"

                        Label {
                            anchors.centerIn: parent
                            font.bold: true
                            text: "Community"
                        }
                    }

                    delegate: Rectangle {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        border.color: "black"
                        color: "lightblue"

                        Text {
                            anchors.centerIn: parent
                            text: index
                        }
                    }

                    Rectangle {
                        border.color: "green"
                        border.width: 5
                        anchors.fill: parent
                        color: "transparent"
                    }
                }

                flickable2: GridView {
                    width: frame.width
                    interactive: false
                    model: secondModel

                    cellWidth: 100
                    cellHeight: 100

                    header: Rectangle {
                        height: root.headerSize
                        width: GridView.view.width

                        color: "red"

                        Label {
                            anchors.centerIn: parent
                            font.bold: true
                            text: "Others"
                        }
                    }

                    delegate: Rectangle {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        border.color: "black"

                        Text {
                            anchors.centerIn: parent
                            text: index
                        }
                    }

                    Rectangle {
                        border.color: "blue"
                        border.width: 5
                        anchors.fill: parent
                        color: "transparent"
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200
        SplitView.fillWidth: true

        Column {
            CheckBox {
                id: clipCheckBox
                text: "clip"
                checked: true
            }

            RowLayout {
                Label {
                    text: "first model:"
                }

                Slider {
                    id: firstSlider
                    from: 0
                    to: 200
                    stepSize: 1

                    value: 160

                    onValueChanged: adjustModel(firstModel, value)
                }

                RoundButton {
                    text: "-"
                    onClicked: firstSlider.decrease()
                }

                RoundButton {
                    text: "+"
                    onClicked: firstSlider.increase()
                }

                Label {
                    text: firstSlider.value
                }
            }

            RowLayout {
                Label {
                    text: "second model:"
                }

                Slider {
                    id: secondSlider
                    from: 0
                    to: 100
                    stepSize: 1

                    value: 90

                    onValueChanged: adjustModel(secondModel, value)
                }

                RoundButton {
                    text: "-"
                    onClicked: secondSlider.decrease()
                }

                RoundButton {
                    text: "+"
                    onClicked: secondSlider.increase()
                }

                Label {
                    text: secondSlider.value
                }
            }
        }
    }
}

// category: Components
