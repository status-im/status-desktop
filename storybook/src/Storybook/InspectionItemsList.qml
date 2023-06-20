import QtQuick 2.15
import QtQuick.Controls 2.15


ListView {
    ScrollBar.vertical: ScrollBar {}

    readonly property color visualItemColor: "blue"
    readonly property color nonVisualItemColor: "black"
    readonly property color selectionColor: "red"

    delegate: Label {
        width: ListView.view.width
        height: implicitHeight * 1.5

        text: " ".repeat(model.level * 4) + " " + model.name

        readonly property color baseColor: model.visual ? visualItemColor
                                                        : nonVisualItemColor

        color: model.item.containsMouse ? selectionColor
                                        : (model.visual ? "blue" : "black")
        elide: Text.ElideRight

        Binding {
            target: model.item
            property: "forceSelect"
            value: mouseArea.containsMouse
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
