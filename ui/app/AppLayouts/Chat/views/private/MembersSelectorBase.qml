import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.Chat.panels 1.0

import utils 1.0
import shared.controls.delegates 1.0

import SortFilterProxyModel 0.2

InlineSelectorPanel {
    id: root

    property ChatStores.RootStore rootStore

    property alias contactsModel: suggestionsModel.sourceModel

    readonly property int membersLimit: 20 // see: https://github.com/status-im/status-mobile/issues/13066
    property bool limitReached: model.count >= membersLimit

    property string pastedChatKey: ""

    label.text: qsTr("To:")
    warningLabel.text: qsTr("%1 USER LIMIT REACHED").arg(membersLimit)
    warningLabel.visible: limitReached

    suggestionsModel: SortFilterProxyModel {
        id: suggestionsModel

        function searchPredicate(displayName, localNickname, nameAlias) {
            return displayName.toLowerCase().includes(root.edit.text.toLowerCase()) ||
                   localNickname.toLowerCase().includes(root.edit.text.toLowerCase()) ||
                   (!displayName && nameAlias.toLowerCase().includes(root.edit.text.toLowerCase()))
        }

        function notAMemberPredicate(pubKey) {
            for(var i = 0; i < model.count; i++) {
                var item = model.get(i)
                if(item.pubKey === pubKey) return false
            }
            return true
        }

        filters: [
            FastExpressionFilter {
                enabled: root.edit.text !== "" && root.pastedChatKey == ""
                expression: {
                    root.edit.text // ensure expression is reevaluated when edit.text changes
                    return suggestionsModel.searchPredicate(model.displayName, model.localNickname, model.alias)
                }
                expectedRoles: ["displayName", "localNickname", "alias"]
            },
            FastExpressionFilter {
                expression: {
                    root.model.count // ensure expression is reevaluated when members model changes
                    return suggestionsModel.notAMemberPredicate(model.pubKey)
                }
                expectedRoles: ["pubKey"]
            },
            ValueFilter {
                roleName: "pubKey"
                value: root.pastedChatKey
                enabled: root.pastedChatKey !== ""
            }
        ]

        sorters: StringSorter {
            roleName: "preferredDisplayName"
            caseSensitivity: Qt.CaseInsensitive
        }
    }

    suggestionsDelegate: ContactListItemDelegate {
        highlighted: ListView.isCurrentItem
        height: root.suggestionsDelegateSize.height
        width: root.suggestionsDelegateSize.width
        onClicked: root.entryAccepted(this)
    }

    Component.onCompleted: {
        root.edit.forceActiveFocus()
    }
}
