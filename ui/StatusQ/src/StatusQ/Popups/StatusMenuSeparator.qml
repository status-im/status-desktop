import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core.Theme 0.1

MenuSeparator {
    height: visible && enabled ? implicitHeight : 0
    contentItem: Rectangle {
        implicitWidth: 176
        implicitHeight: 1
        color: Theme.palette.statusPopupMenu.separatorColor
    }
}
