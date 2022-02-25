import QtQuick 2.13
import QtQuick.Layouts 1.13
import StatusQ.Components 0.1

import shared 1.0

import utils 1.0

Column {
    id: root
    spacing: 4

    property var privacyStore
    property alias mainMenuItems: mainMenuItems.model
    property alias settingsMenuItems: settingsMenuItems.model
    property alias extraMenuItems: extraMenuItems.model
    property alias appsMenuItems: appsMenuItems.model

    property bool browserMenuItemEnabled: false
    property bool appsMenuItemsEnabled: false

    signal menuItemClicked(var menu_item)

    Repeater {
        id: mainMenuItems
        delegate: StatusNavigationListItem {
            itemId: model.subsection
            title: model.text
            icon.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
        }
    }

    StatusListSectionHeadline { 
        text: qsTr("Apps")
        visible: root.appsMenuItemsEnabled
    }
    
    Repeater {
        id: appsMenuItems
        delegate: StatusNavigationListItem {
            id: appsMenuDelegate
            itemId: model.subsection
            title: model.text
            icon.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
            visible: root.appsMenuItemsEnabled
        }
    }

    StatusListSectionHeadline { text: qsTr("Settings") }

    Repeater {
        id: settingsMenuItems
        delegate: StatusNavigationListItem {
            id: settingsMenuDelegate
            itemId: model.subsection
            title: model.text
            icon.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
            visible: model.subsection !== Constants.settingsSubsection.browserSettings || root.browserMenuItemEnabled
            badge.value: !root.privacyStore.mnemonicBackedUp && settingsMenuDelegate.title === qsTr("Privacy and security")
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
            itemId: model.subsection
            title: model.text
            icon.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            visible: model.subsection !== Constants.settingsSubsection.browserSettings || root.browserMenuItemEnabled
            onClicked: root.menuItemClicked(model)
        }
    }
}

