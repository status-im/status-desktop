import QtQuick
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Components.private
import StatusQ.Core.Theme

import Models
import Storybook

SplitView {
    id: root

    ButtonGroup {
        buttons: column.children
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        color: thirdpartyServicesCtrl.checked ? Theme.palette.statusAppNavBar.backgroundColor: Theme.palette.privacyModeColor

        Column {
            id: column
            spacing: 8
            anchors.centerIn: parent

            StatusNavBarTabButton {
                name: "name only"
                tooltip.text: "With 'name' only, active"
                checked: true
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.name: "help"
                tooltip.text: "With icon"
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.name: "help"
                tooltip.text: "Disabled with icon"
                enabled: false
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.source: ModelsData.icons.socks
                tooltip.text: "With image"
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.name: "help"
                tooltip.text: "With icon & badge dot"
                badge.visible: true
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.name: "help"
                tooltip.text: "With icon & badge value (small)"
                badge.value: 3
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                icon.name: "help"
                tooltip.text: "With icon & badge value (big)"
                badge.value: 100
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked
            }
            StatusNavBarTabButton {
                id: communityButton
                icon.name: "communities"
                tooltip.text: ctrlNewBadgeGradient.checked ? "With custom badge gradient" : "With blue notification dot"
                thirdpartyServicesEnabled: thirdpartyServicesCtrl.checked

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
    }

    Column {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        CheckBox {
            id: ctrlNewBadgeGradient
            text: "Custom badge gradient"
            checked: true
        }
        CheckBox {
            id: thirdpartyServicesCtrl
            text: "Enable ThirdParty Services"
            checked: true
        }
    }
}

// category: Controls
// status: good
