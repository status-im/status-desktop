import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.stores 1.0

import utils 1.0

import SortFilterProxyModel 0.2

import "private"

MembersSelectorBase {
    id: root

    property var usersModel
    property var temporaryUsersModel
    property bool amIChatAdmin

    signal updateGroupMembers()
    signal resetTemporaryUsersModel()
    signal appendTemporaryUsersModel(string pubKey, string displayName)
    signal removeFromTemporaryUsersModel(string pubKey)

    onConfirmed: {
        root.updateGroupMembers()
        root.resetTemporaryUsersModel()
    }

    onRejected: {
        root.resetTemporaryUsersModel()
    }

    onEntryAccepted: if (suggestionsDelegate) {
        if (!root.limitReached) {
            root.appendTemporaryUsersModel(suggestionsDelegate._pubKey, suggestionsDelegate.userName)
            root.edit.clear()
        }
    }

    onEntryRemoved: if (delegate) {
        if (!delegate.isReadonly) {
            root.removeFromTemporaryUsersModel(delegate._pubKey)
        }
    }

    model: SortFilterProxyModel {
        sourceModel: root.temporaryUsersModel
        sorters: RoleSorter {
            roleName: "memberRole"
            sortOrder: Qt.DescendingOrder
        }
    }

    delegate: StatusTagItem {
        readonly property string _pubKey: model.pubKey

        height: ListView.view.height
        text: model.preferredDisplayName

        isReadonly: {
            if (model.memberRole === Constants.memberRole.owner) return true
            if (root.amIChatAdmin) return false
            return index < root.usersModel.count
        }
        icon: model.memberRole === Constants.memberRole.owner ? "crown" : ""

        onClosed: root.entryRemoved(this)
    }

    Component.onCompleted: {
        root.resetTemporaryUsersModel()
    }
}
