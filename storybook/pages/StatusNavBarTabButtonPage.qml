import QtQuick
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Components.private

import Models
import Storybook

Item {
    id: root

    ButtonGroup {
        buttons: column.children
    }

    Column {
        id: column
        spacing: 8
        anchors.centerIn: parent

        StatusNavBarTabButton {
            name: "name only"
            tooltip.text: "With 'name' only, active"
            checked: true
        }
        StatusNavBarTabButton {
            icon.name: "help"
            tooltip.text: "With icon"
        }
        StatusNavBarTabButton {
            icon.name: "help"
            tooltip.text: "Disabled with icon"
            enabled: false
        }
        StatusNavBarTabButton {
            icon.source: ModelsData.icons.socks
            tooltip.text: "With image"
        }
        StatusNavBarTabButton {
            icon.name: "help"
            tooltip.text: "With icon & badge dot"
            badge.visible: true
        }
        StatusNavBarTabButton {
            icon.name: "help"
            tooltip.text: "With icon & badge value (small)"
            badge.value: 3
        }
        StatusNavBarTabButton {
            icon.name: "help"
            tooltip.text: "With icon & badge value (big)"
            badge.value: 100
        }
        StatusNavBarTabButton {
            id: communityButton
            icon.name: "communities"
            tooltip.text: ctrlNewBadgeGradient.checked ? "With custom badge gradient" : "With blue notification dot"

            StatusNewItemGradient { id: grad }
            badge.visible: true
            badge.gradient: ctrlNewBadgeGradient.checked ? grad : undefined

            // BUG: Binding below doesn't work
            // Binding on badge.gradient {
            //     value: StatusNewItemGradient {}
            //     when: ctrlNewBadgeGradient.checked
            // }
        }
    }

    CheckBox {
        id: ctrlNewBadgeGradient
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Custom badge gradient"
        checked: true
    }
}

// category: Controls
// status: good
