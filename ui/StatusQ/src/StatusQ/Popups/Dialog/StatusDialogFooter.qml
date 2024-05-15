import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property ObjectModel leftButtons
    property ObjectModel rightButtons
    property int spacing: 5
    property bool dropShadowEnabled

    color: Theme.palette.statusModal.backgroundColor
    radius: 8

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    // cover for the top rounded corners
    Rectangle {
        width: parent.width
        height: parent.radius
        anchors.top: parent.top
        color: parent.color
    }

    StatusDialogDivider {
        anchors.top: parent.top
        width: parent.width
        visible: !root.dropShadowEnabled
    }

    RowLayout {
        id: layout

        spacing: root.spacing
        clip: true

        anchors {
            fill: parent
            margins: 16
        }

        Repeater {
            model: root.leftButtons
            onItemAdded: {
                item.Layout.fillHeight = true
                item.Layout.fillWidth = Qt.binding(() => root.width < root.implicitWidth)
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Repeater {
            model: root.rightButtons
            onItemAdded: {
                item.Layout.fillHeight = true
                item.Layout.fillWidth = Qt.binding(() => root.width < root.implicitWidth)
            }
        }
    }

    layer.enabled: root.dropShadowEnabled
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: -2
        samples: 37
        color: Theme.palette.dropShadow
    }
}
