import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Controls

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusSwitchTabBar {
        StatusSwitchTabButton {
            text: "Swap"
        }
        StatusSwitchTabButton {
            text: "Swap & Send"
        }
        StatusSwitchTabButton {
            text: "Send"
        }
    }
}

