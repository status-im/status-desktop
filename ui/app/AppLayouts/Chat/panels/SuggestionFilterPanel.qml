import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import SortFilterProxyModel 0.2

SQUtils.QObject {
    id: root

    required property var sourceModel
    property string filter: ""
    property int cursorPosition: 0
    property int lastAtPosition: -1

    readonly property alias model: filteredModel // resulting, filtered model
    readonly property string formattedFilter: getFilter().substring(lastAtPosition + 1, cursorPosition).replace(/\*/g, "")

    onFilterChanged: invalidateFilter()

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: concatModel
        filters: SQUtils.SearchFilter {
            roleName: "preferredDisplayName"
            searchPhrase: root.formattedFilter
        }
        sorters: StringSorter {
            roleName: "preferredDisplayName"
            caseSensitivity: Qt.CaseInsensitive
        }
    }

    ConcatModel {
        id: concatModel
        sources: [
            SourceModel {
                model: root.sourceModel
                markerRoleValue: "filtered_model"
            },
            SourceModel {
                model: ListModel {
                    ListElement {
                        pubKey: "0x00001"
                        preferredDisplayName: "everyone"
                        icon: ""
                        colorId: 0
                        colorHash: []
                        usesDefaultName: false
                    }
                }
                markerRoleValue: "everyone_model"
            }
        ]
        markerRoleName: "which_model"
        expectedRoles: ["pubKey", "preferredDisplayName"]
    }

    function invalidateFilter() {
        root.lastAtPosition = -1

        let filter = getFilter()
        if (filter === "") {
            return
        }

        for (let c = root.cursorPosition === 0 ? 0 : (root.cursorPosition-1); c >= 0; c--) {
            if (filter.charAt(c) === "@") {
                root.lastAtPosition = c
                break
            }
        }
    }

    function getFilter() {
        if (root.filter.length === 0 || root.cursorPosition === 0) {
            return ""
        }

        return SQUtils.StringUtils.plainText(root.filter)
    }
}
