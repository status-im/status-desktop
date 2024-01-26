import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import QtQuick.Controls 2.15
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

StatusListView {
    id: root

    property string placeholderText

    ScrollBar.vertical: null

    QtObject {
        id: d

        readonly property int placeholderHeight: 44
    }

    Binding {
        when: root.model && root.count === 0
        target: root
        property: "footer"
        restoreMode: Binding.RestoreBindingOrValue

        value: Component {
            Item {
                height: d.placeholderHeight
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
