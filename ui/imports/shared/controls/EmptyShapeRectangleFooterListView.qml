import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

import StatusQ.Core 0.1

StatusListView {
    id: root

    property string placeholderText
    property int placeholderHeight: 44

    // TO BE REMOVE: #13498
    property bool empty: root.model && root.count === 0

    ScrollBar.vertical: null

    Binding {
        when: root.empty// TO BE REPLACE by (#13498):  root.model && root.count === 0
        target: root
        property: "footer"
        restoreMode: Binding.RestoreBindingOrValue

        value: Component {
            Item {
                height: root.placeholderHeight
                width: root.width

                ShapeRectangle {
                    id: shapeRectangle

                    text: root.placeholderText

                    anchors.fill: parent
                    anchors.margins: 1
                }
            }
        }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
    }
}
