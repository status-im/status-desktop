import QtQuick

import StatusQ.Controls

Item {
    StatusLabeledSlider {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20

        textRole: "name"
        valueRole: "value"

        model: ListModel {
            ListElement { name: qsTr("XS"); value: 1 }
            ListElement { name: qsTr("S"); value: 2 }
            ListElement { name: qsTr("M"); value: 3 }
            ListElement { name: qsTr("L"); value: 4 }
            ListElement { name: qsTr("XL"); value: 5 }
            ListElement { name: qsTr("XXL"); value: 6 }
        }
    }
}

// category: Controls
// status: good
