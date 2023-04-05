import QtQuick 2.15

import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    required property bool cursorVisible

    color: Theme.palette.primaryColor1
    implicitWidth: 2
    implicitHeight: 22
    radius: 1
    visible: cursorVisible

    SequentialAnimation on visible {
        loops: Animation.Infinite
        running: root.cursorVisible
        PropertyAnimation { to: false; duration: Qt.styleHints.cursorFlashTime / 2 }
        PropertyAnimation { to: true; duration: Qt.styleHints.cursorFlashTime / 2 }
    }
}
