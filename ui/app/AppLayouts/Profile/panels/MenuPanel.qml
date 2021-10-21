import QtQuick 2.13
import QtQuick.Layouts 1.13
import StatusQ.Components 0.1

import "../../../../shared"

import utils 1.0

Column {
    id: root
    spacing: 4

    property alias mainMenuItems: mainMenuItems.model
    property alias settingsMenuItems: settingsMenuItems.model
    property alias extraMenuItems: extraMenuItems.model

    property int selectedMenuItem
    property bool browserMenuItemEnabled: false

    signal menuItemClicked(var menu_item)

    Repeater {
        id: mainMenuItems
        delegate: StatusNavigationListItem {
            itemId: model.menu_id
            title: model.text
            icon.name: model.icon
            selected: root.selectedMenuItem === model.menu_id
            onClicked: root.menuItemClicked(model)
        }
    }

    StatusListSectionHeadline { text: qsTr("Settings") }

    Repeater {
        id: settingsMenuItems
        delegate: StatusNavigationListItem {
            id: settingsMenuDelegate
            itemId: model.menu_id
            title: model.text
            icon.name: model.icon
            selected: root.selectedMenuItem === model.menu_id
            onClicked: root.menuItemClicked(model)
            visible: model.ifEnabled !== "browser" || root.browserMenuItemEnabled
            badge.value: (!mnemonicModule.isBackedUp && (settingsMenuDelegate.title ===
                        settingsMenuItems.itemAt(0).text)) ? 1 : 0
        }
    }

    Item {
        id: invisibleSeparator
        height: 16
        width: parent.width
    }

    Repeater {
        id: extraMenuItems
        delegate: StatusNavigationListItem {
            itemId: model.menu_id
            title: model.text
            icon.name: model.icon
            selected: root.selectedMenuItem === model.menu_id
            visible: model.ifEnabled !== "browser" || root.browserMenuItemEnabled
            onClicked: root.menuItemClicked(model)
        }
    }
}

