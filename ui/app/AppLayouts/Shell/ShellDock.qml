import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import utils 1.0

TabBar {
    id: root

    required property var sectionsModel

    property bool useNewDockIcons: true

    signal itemActivated(int sectionType, string itemId)

    padding: Theme.smallPadding
    spacing: Theme.smallPadding

    background: Rectangle {
        color: "#161d27"
        radius: Theme.smallPadding * 2
    }

    Repeater {
        model: SortFilterProxyModel {
            sourceModel: root.sectionsModel
            filters: [
                // ValueFilter {
                //     roleName: "enabled"
                //     value: true
                // },
                ValueFilter {
                    roleName: "sectionType"
                    value: Constants.appSection.community
                    inverted: true
                }
            ]
            sorters: [
                FilterSorter {
                    ValueFilter { roleName: "sectionType"; value: Constants.appSection.profile; inverted: true } // Settings last
                },
                FilterSorter {
                    ValueFilter { roleName: "sectionType"; value: Constants.appSection.node; inverted: true } // Node second last
                },
                RoleSorter { roleName: "sectionType" }
            ]
        }
        delegate: ShellDockButton {
            icon.name: (root.useNewDockIcons ? "shell/" : "") + model.icon
            sectionType: model.sectionType
            hasNotification: model.hasNotification
            notificationsCount: model.notificationsCount
            enabled: model.enabled
            onClicked: root.itemActivated(sectionType, model.id)
        }
    }
}
