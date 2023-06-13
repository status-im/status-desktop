import QtQuick 2.13
import QtQuick.Layouts 1.13
import StatusQ.Components 0.1

import shared 1.0

import utils 1.0

Column {
    id: root
    spacing: 8

    property var privacyStore
    property var contactsStore
    property alias mainMenuItems: mainMenuItems.model
    property alias settingsMenuItems: settingsMenuItems.model
    property alias extraMenuItems: extraMenuItems.model
    property alias appsMenuItems: appsMenuItems.model

    property bool browserMenuItemEnabled: false
    property bool walletMenuItemEnabled: false

    signal menuItemClicked(var menu_item)

    Repeater {
        id: mainMenuItems
        delegate: StatusNavigationListItem {
            objectName: itemId + "-MainMenuItem"
            width: root.width
            itemId: model.subsection
            title: model.text
            asset.name: model.icon
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
        width: root.width
    }
    
    Repeater {
        id: appsMenuItems
        delegate: StatusNavigationListItem {
            id: appsMenuDelegate
            objectName: itemId + "-AppMenuItem"
            width: root.width
            itemId: model.subsection
            title: model.text
            asset.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
            visible: {
                (model.subsection !== Constants.settingsSubsection.browserSettings && model.subsection !== Constants.settingsSubsection.wallet) ||
                (model.subsection === Constants.settingsSubsection.browserSettings && root.browserMenuItemEnabled) ||        
                (model.subsection === Constants.settingsSubsection.communitiesSettings) ||
                (model.subsection === Constants.settingsSubsection.wallet && root.walletMenuItemEnabled)
            }
            badge.value: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.messaging:
                        return root.contactsStore.receivedContactRequestsModel.count
                    default: return ""
                }
            }
        }
    }

    StatusListSectionHeadline {
        text: qsTr("Settings")
        width: root.width
    }

    Repeater {
        id: settingsMenuItems
        delegate: StatusNavigationListItem {
            id: settingsMenuDelegate
            objectName:  itemId + "-SettingsMenuItem"
            width: root.width
            itemId: model.subsection
            title: model.text
            asset.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            onClicked: root.menuItemClicked(model)
            visible: model.subsection !== Constants.settingsSubsection.browserSettings || root.browserMenuItemEnabled
        }
    }

    StatusListSectionHeadline {
        text: qsTr("About & Help")
        width: root.width
    }

    Repeater {
        id: extraMenuItems
        delegate: StatusNavigationListItem {
            objectName:  itemId + "-ExtraMenuItem"
            width: root.width
            itemId: model.subsection
            title: model.text
            asset.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            visible: model.subsection !== Constants.settingsSubsection.browserSettings || root.browserMenuItemEnabled
            onClicked: root.menuItemClicked(model)
        }
    }
}
