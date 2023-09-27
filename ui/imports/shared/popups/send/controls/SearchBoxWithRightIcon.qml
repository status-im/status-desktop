import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusInput {
    property bool showTopBorder: false

    placeholderText: qsTr("Search")
    input.implicitHeight: 56
    input.background.color: Theme.palette.indirectColor1
    input.background.border.width: 0
    input.rightComponent: StatusFlatRoundButton {
        icon.name: "search"
        type: StatusFlatRoundButton.Type.Secondary
        enabled: false
    }
    Rectangle {
        visible: showTopBorder
        anchors.top: parent.top
        height: 1
        width: parent.width
        color: Theme.palette.baseColor2
    }
    Rectangle {
        anchors.bottom: parent.bottom
        height: 1
        width: parent.width
        color: Theme.palette.baseColor2
    }
}
