import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1

import utils 1.0

ListView {
    id: root

    // adds drag handler to every row, emits moveRequested when item is moved
    property bool movable: false

    // roles intended to be visualized, all roles when empty
    property var roles: []

    // custom delegate height, when set to 0, delegate's implicitHeight is used
    property int delegateHeight: 0

    // text to be displayed in a list view's header
    property string label

    // additional component to be instantiated within every delegate
    property Component insetComponent

    property int margin: 5

    ScrollBar.vertical: ScrollBar {}

    clip: true
    spacing: 5

    leftMargin: margin
    rightMargin: margin
    topMargin: margin
    bottomMargin: margin

    signal moveRequested(int from, int to)

    ListModel {
        id: rowModel

        function initialize() {
            const roleNames = roles.length ? roles
                                           : ModelUtils.roleNames(root.model)
            const modelContent = roleNames.map(roleName => ({ roleName }))

            clear()
            append(modelContent)
        }

        Component.onCompleted: initialize()
    }

    Connections {
        target: root.model

        function onRowsInserted() {
            if (rowModel.count === 0)
                rowModel.initialize()
        }

        function onModelReset() {
            rowModel.initialize()
        }
    }

    Rectangle {
        border.color: "lightgray"
        color: "transparent"
        anchors.fill: parent
    }

    header: Label {
        visible: !!text
        height: visible ? undefined : 0
        text: root.label
        font.bold: true
        font.pixelSize: 16
        bottomPadding: 20
    }

    delegate: Item {
        id: delegateRoot

        width: ListView.view.width
        height: root.delegateHeight || delegateRow.implicitHeight

        readonly property var topModel: model

        RowLayout {
            id: delegateRow

            Drag.active: dragArea.pressed
            Drag.source: dragArea
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            anchors.fill: delegateRoot

            states: State {
                when: dragArea.pressed

                ParentChange {
                    target: delegateRow
                    parent: root
                }

                AnchorChanges {
                    target: delegateRow
                    anchors {
                        horizontalCenter: undefined
                        verticalCenter: undefined
                    }
                }
            }

            RoundButton {
                text: "↕️"
                visible: root.movable

                MouseArea {
                    id: dragArea

                    property bool held: pressed
                    readonly property int idx: model.index

                    anchors.fill: parent

                    drag.target: pressed ? delegateRow : undefined
                    drag.axis: Drag.YAxis
                }
            }
            Loader {
                readonly property var model: delegateRoot.topModel
                sourceComponent: insetComponent
            }

            Flow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Repeater {
                    model: rowModel

                    Label {
                        readonly property var value:
                            delegateRoot.topModel[roleName]

                        readonly property var valueSanitized:
                            value === undefined ? "-" : value

                        readonly property bool last: index === rowModel.count - 1
                        readonly property string separator: last ? "" : ","

                        text: `${roleName}: ${valueSanitized}${separator}`
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        DropArea {
            anchors { fill: parent; margins: 10 }

            onEntered: {
                const from = drag.source.idx
                const to = dragArea.idx

                if (from === to)
                    return

                root.moveRequested(from, to)
            }
        }
    }
}
