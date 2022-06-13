import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property ObjectModel leftButtons
    property ObjectModel rightButtons

    color: Theme.palette.statusModal.backgroundColor
    radius: 8

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    RowLayout {
        id: layout

        clip: true

        anchors {
            fill: parent
            margins: 16
        }

        Repeater {
            model: root.leftButtons
            onItemAdded: item.Layout.fillHeight = true
        }

        Item {
            Layout.fillWidth: true
        }

        Repeater {
            model: root.rightButtons
            onItemAdded: item.Layout.fillHeight = true
        }
    }

    StatusDialogDivider {
        width: parent.width
    }
}
