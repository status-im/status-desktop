import QtQuick 2.13
import QtQuick.Layouts 1.13
import StatusQ.Components 0.1

import shared 1.0

import utils 1.0

Column {
    id: root
    spacing: 4

    property var privacyStore
    property var messagingStore
    property alias mainMenuItems: mainMenuItems.model
    property alias settingsMenuItems: settingsMenuItems.model
    property alias extraMenuItems: extraMenuItems.model
    property alias appsMenuItems: appsMenuItems.model

    property bool browserMenuItemEnabled: false
    property bool walletMenuItemEnabled: false
    property bool appsMenuItemsEnabled: false
    property bool communitiesMenuItemEnabled: false

    signal menuItemClicked(var menu_item)

    Repeater {
        id: mainMenuItems
        delegate: StatusNavigationListItem {
            itemId: model.subsection
            title: model.text
            icon.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
            badge.value: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.backUpSeed:
                        return !root.privacyStore.mnemonicBackedUp
                    default: return "";
                }
            }
            visible: {
                switch (model.subsection) {
                case Constants.settingsSubsection.ensUsernames:
                    return root.walletMenuItemEnabled;
                case Constants.settingsSubsection.backUpSeed:
                    return !root.privacyStore.mnemonicBackedUp;
                default: return true;
                }
            }
        }
    }

    StatusListSectionHeadline { 
        text: qsTr("Apps")
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
            visible: {
                (model.subsection !== Constants.settingsSubsection.browserSettings && model.subsection !== Constants.settingsSubsection.wallet && model.subsection !== Constants.settingsSubsection.communitiesSettings) ||
                (model.subsection === Constants.settingsSubsection.browserSettings && root.browserMenuItemEnabled) ||        
                (model.subsection === Constants.settingsSubsection.communitiesSettings && root.communitiesMenuItemEnabled) ||
                (model.subsection === Constants.settingsSubsection.wallet && root.appsMenuItemsEnabled)
            }
            badge.value: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.messaging:
                        return root.messagingStore.contactRequestsModel.count
                    default: return ""
                }
            }
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
        }
    }

    StatusListSectionHeadline { text: qsTr("About & Help") }

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

