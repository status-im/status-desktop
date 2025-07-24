import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils

import AppLayouts.Chat.stores as ChatStores
import AppLayouts.Chat.panels

import utils
import shared.controls.delegates

import SortFilterProxyModel

InlineSelectorPanel {
    id: root

    property alias contactsModel: suggestionsModel.sourceModel

    readonly property int membersLimit: 20 // see: https://github.com/status-im/status-mobile/issues/13066
    property bool limitReached: model.count >= membersLimit

    property string pastedChatKey: ""

    label.text: qsTr("To:")
    warningLabel.text: qsTr("%1 USER LIMIT REACHED").arg(membersLimit)
    warningLabel.visible: limitReached

    suggestionsModel: SortFilterProxyModel {
        id: suggestionsModel

        function notAMemberPredicate(pubKey) {
            return !ModelUtils.contains(model, "pubKey", pubKey)
        }

        filters: [
            AnyOf {
                enabled: root.edit.text !== "" && root.pastedChatKey == ""
                SearchFilter {
                    roleName: "alias"
                    searchPhrase: root.edit.text
                }
                SearchFilter {
                    roleName: "displayName"
                    searchPhrase: root.edit.text
                }
                SearchFilter {
                    roleName: "ensName"
                    searchPhrase: root.edit.text
                }
                SearchFilter {
                    roleName: "localNickname"
                    searchPhrase: root.edit.text
                }
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
