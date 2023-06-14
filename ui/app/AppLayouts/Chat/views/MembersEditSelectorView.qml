import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "../panels"
import "../stores"
import "private"

import utils 1.0

import SortFilterProxyModel 0.2

MembersSelectorBase {
    id: root

    property var usersStore

    onConfirmed: {
        usersStore.updateGroupMembers()
        usersStore.resetTemporaryModel()
    }

    onRejected: {
        usersStore.resetTemporaryModel()
    }

    onEntryAccepted: if (suggestionsDelegate) {
        if (!root.limitReached) {
            usersStore.appendTemporaryModel(suggestionsDelegate._pubKey, suggestionsDelegate.userName)
            root.edit.clear()
        }
    }

    onEntryRemoved: if (delegate) {
        if (!delegate.isReadonly) {
            usersStore.removeFromTemporaryModel(delegate._pubKey)
        }
    }

    model: SortFilterProxyModel {
        sourceModel: root.usersStore.temporaryModel
        sorters: RoleSorter {
            roleName: "memberRole"
            sortOrder: Qt.DescendingOrder
        }
    }

    delegate: StatusTagItem {
        readonly property string _pubKey: model.pubKey

        height: ListView.view.height
        text: root.tagText(model.localNickname, model.displayName, model.alias)

        isReadonly: {
            if (model.memberRole === Constants.memberRole.owner) return true
            if (root.rootStore.amIChatAdmin()) return false
            return index < root.usersStore.usersModel.count
        }
        icon: model.memberRole === Constants.memberRole.owner ? "crown" : ""

        onClosed: root.entryRemoved(this)
    }

    Component.onCompleted: {
        usersStore.resetTemporaryModel()
    }
}
