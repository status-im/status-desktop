import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

GridLayout {
    columns: 6
    columnSpacing: 5
    rowSpacing: 5
    property ThemePalette theme

    StatusIconTabButton {
        icon.name: "chat"
    }

    StatusIconTabButton {
        icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
    }

    StatusIconTabButton {
        name: "#status"
    }

    Button {
        text: "Hover me!"
        StatusToolTip {
            visible: parent.hovered
            text: "Top"
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Right"
            orientation: StatusToolTip.Orientation.Right
            x: parent.width + 16
            y: parent.height / 2 - height / 2 + 4
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Bottom"
            orientation: StatusToolTip.Orientation.Bottom
            y: parent.height + 12
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Left"
            orientation: StatusToolTip.Orientation.Left
            x: -parent.width /2 -8
            y: parent.height / 2 - height / 2 + 4
        }
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
    }

    StatusNavBarTabButton {
        name: "#status"
        tooltip.text: "Some Channel"
    }

    StatusNavBarTabButton {
        icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        tooltip.text: "Some Community"
    }

    StatusNavBarTabButton {
        icon.name: "profile"
        tooltip.text: "Profile"
        badge.value: 0
        badge.visible: true
        badge.anchors.leftMargin:-16
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
        badge.value: 35
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
        badge.value: 100
    }

    StatusSwitch {

    }

    StatusRadioButton {
        text: "i'm radio!"
    }
}
