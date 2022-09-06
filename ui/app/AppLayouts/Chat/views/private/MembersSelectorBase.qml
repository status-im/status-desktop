import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "../../panels"

import utils 1.0
import shared.controls.delegates 1.0

import SortFilterProxyModel 0.2

InlineSelectorPanel {
    id: root

    property var rootStore
    readonly property bool limitReached: model.count >= d.membersLimit

    label.text: qsTr("To:")
    warningLabel.text: qsTr("%1 USER LIMIT REACHED").arg(d.membersLimit)
    warningLabel.visible: limitReached

    suggestionsModel: SortFilterProxyModel {
        id: _suggestionsModel

        sourceModel: root.rootStore.contactsModel

        function searchPredicate(displayName) {
            return displayName.toLowerCase().includes(root.edit.text.toLowerCase())
        }

        function notAMemberPredicate(pubKey) {
            for(var i = 0; i < model.count; i++) {
                var item = model.get(i)
                if(item.pubKey === pubKey) return false
            }
            return true
        }

        filters: [
            ExpressionFilter {
                enabled: root.edit.text !== ""
                expression: {
                    root.edit.text // ensure expression is reevaluated when edit.text changes
                    return _suggestionsModel.searchPredicate(model.displayName)
                }
            },
            ExpressionFilter {
                expression: {
                    root.model.count // ensure expression is reevaluated when members model changes
                    return _suggestionsModel.notAMemberPredicate(model.pubKey)
                }
            }
        ]
        sorters: StringSorter {
            roleName: "displayName"
        }
    }

    suggestionsDelegate: ContactListItemDelegate {
        highlighted: ListView.isCurrentItem
        onClicked: root.entryAccepted(this)
    }

    QtObject {
        id: d

        readonly property int membersLimit: 20 // see: https://github.com/status-im/status-mobile/issues/13066
    }

    Component.onCompleted: {
        root.edit.forceActiveFocus()
    }
}
