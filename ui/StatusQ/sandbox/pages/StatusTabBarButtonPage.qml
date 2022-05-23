import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusTabBar {
        StatusTabButton {
            width: implicitWidth
            text: "Button 1"
        }
        StatusTabButton {
            width: implicitWidth
            text: "Button 2"
        }
        StatusTabButton {
            width: implicitWidth
            text: "Button 3"
            badge.value: 42
        }
    }
}
