import QtQuick

import StatusQ.Controls
import StatusQ.Core.Theme

StatusInput {
    property bool showTopBorder: false
    property bool showBottomBorder: true

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
        visible: showBottomBorder
        anchors.bottom: parent.bottom
        height: 1
        width: parent.width
        color: Theme.palette.baseColor2
    }
}
