import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

MenuSeparator {
    height: visible && enabled ? implicitHeight : 0
    background: null
    contentItem: Rectangle {
        implicitWidth: 176
        implicitHeight: 1
        color: Theme.palette.statusMenu.separatorColor
    }
}
