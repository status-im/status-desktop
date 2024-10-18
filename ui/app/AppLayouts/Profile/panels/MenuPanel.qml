import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import utils 1.0

import "../stores"

Column {
    id: root
    spacing: 8

    property PrivacyStore privacyStore
    property ContactsStore contactsStore
    property DevicesStore devicesStore
    property alias mainMenuItems: mainMenuItems.model
    property alias settingsMenuItems: settingsMenuItems.model
    property alias extraMenuItems: extraMenuItems.model
    property alias appsMenuItems: appsMenuItems.model

    property bool walletMenuItemEnabled: false

    signal menuItemClicked(var menu_item)

    Repeater {
        id: mainMenuItems
        delegate: StatusNavigationListItem {
            id: navigationItem
            objectName: itemId + "-MainMenuItem"
            width: root.width
            itemId: model.subsection
            title: model.text
            asset.name: model.icon
            selected: Global.settingsSubsection === model.subsection
            highlighted: !!betaTagLoader.item && betaTagLoader.item.hovered
            onClicked: root.menuItemClicked(model)
            badge.value: {
                switch (model.subsection) {
                    case Constants.settingsSubsection.backUpSeed:
                        return !root.privacyStore.mnemonicBackedUp
                    case Constants.settingsSubsection.syncingSettings:
                        return root.devicesStore.devicesModel.count - root.devicesStore.devicesModel.pairedCount
                    default: return 0
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

            Loader {
                id: betaTagLoader
                readonly property string experimentalTooltip: model.experimentalTooltip ?? ""
                active: model.isExperimental
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.padding + (navigationItem.badge.visible ? navigationItem.badge.width + Theme.halfPadding : 0)

                sourceComponent: StatusBetaTag {
                    tooltipText: betaTagLoader.experimentalTooltip
                    cursorShape: Qt.PointingHandCursor
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
                (model.subsection !== Constants.settingsSubsection.wallet) ||
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
        text: qsTr("Preferences")
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
            onClicked: root.menuItemClicked(model)
        }
    }
}
