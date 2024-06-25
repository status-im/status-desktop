import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "../../panels"

import AppLayouts.Chat.stores 1.0 as ChatStores

import utils 1.0
import shared.controls.delegates 1.0

import SortFilterProxyModel 0.2

InlineSelectorPanel {
    id: root

    property ChatStores.RootStore rootStore

    readonly property int membersLimit: 20 // see: https://github.com/status-im/status-mobile/issues/13066
    property bool limitReached: model.count >= membersLimit

    function tagText(localNickname, displayName, aliasName) {
        return localNickname || displayName || aliasName
    }

    property string pastedChatKey: ""

    label.text: qsTr("To:")
    warningLabel.text: qsTr("%1 USER LIMIT REACHED").arg(membersLimit)
    warningLabel.visible: limitReached

    suggestionsModel: SortFilterProxyModel {
        id: _suggestionsModel

        sourceModel: root.rootStore.contactsModel

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

        function isPastedProfileLinkToContact(pubkey) {
            return root.pastedChatKey === pubkey
        }

        filters: [
            ExpressionFilter {
                enabled: root.edit.text !== "" && root.pastedChatKey == ""
                expression: {
                    root.edit.text // ensure expression is reevaluated when edit.text changes
                    return _suggestionsModel.searchPredicate(model.displayName, model.localNickname, model.alias)
                }
            },
            ExpressionFilter {
                expression: {
                    root.model.count // ensure expression is reevaluated when members model changes
                    return _suggestionsModel.notAMemberPredicate(model.pubKey)
                }
            },
            ExpressionFilter {
                enabled: root.pastedChatKey != ""
                expression: {
                    root.pastedChatKey // ensure expression is reevaluated when members model changes
                    return _suggestionsModel.isPastedProfileLinkToContact(model.pubKey)
                }
            }
        ]

        proxyRoles: ExpressionRole {
            name: "title"
            expression: model.localNickname || model.displayName || model.alias
        }

        sorters: StringSorter {
            roleName: "title"
            numericMode: true
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
