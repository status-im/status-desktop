import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        CustomStatusSwitchTabBar {}
        CustomStatusSwitchTabBar {
            buttonWidth: 100
        }
        CustomStatusSwitchTabBar {
            tabBarWidth: 300
        }
    }

    component CustomStatusSwitchTabBar: Column {
        id: customTabBar
        spacing: 3

        property var tabBarWidth
        property var buttonWidth

        Label {
            text: "StatusSwitchTabBar width: %1; StatusSwitchTabButton width: %2".arg(tabBarWidth).arg(buttonWidth)
        }
        StatusSwitchTabBar {
            width: customTabBar.tabBarWidth
            Repeater {
                id: repeater
                model: [12, 18, 24, "Too many"]
                StatusSwitchTabButton {
                    width: customTabBar.buttonWidth ?? implicitWidth
                    text: "%1 words".arg(modelData)
                    showBetaTag: index === repeater.count - 1
                }
            }
        }
    }
}

// category: Controls
// status: good
