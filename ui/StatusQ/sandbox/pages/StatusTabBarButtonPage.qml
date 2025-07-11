import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

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
