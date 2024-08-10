import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

TabBar {
    padding: 1

    implicitHeight: 36

    background: Rectangle {
        color: Theme.palette.statusSwitchTab.barBackgroundColor
        radius: 8
    }
}
