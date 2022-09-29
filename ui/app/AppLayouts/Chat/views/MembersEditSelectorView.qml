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

    // TODO: use stores instead of modules
    property var sectionModule
    property var chatContentModule

    confirmBtnEnabled: true
    onConfirmed: {
        d.updateGroupMembers()
        d.resetTemporaryModel()
    }

    onRejected: {
        d.resetTemporaryModel()
    }
    limitReached: (model.count === membersLimit)
    onEntryAccepted: {
        if (!root.limitReached) {
            d.appendTemporaryModel(suggestionsDelegate._pubKey, suggestionsDelegate.userName)
            root.edit.clear()
        }
    }

    onEntryRemoved: {
        if (!delegate.isReadonly) {
            d.removeFromTemporaryModel(delegate._pubKey)
        }
    }

    model: SortFilterProxyModel {
        sourceModel: root.chatContentModule.usersModule.temporaryModel
        sorters: RoleSorter {
            roleName: "isAdmin"
            sortOrder: Qt.DescendingOrder
        }
    }

    delegate: StatusTagItem {
        readonly property string _pubKey: model.pubKey

        height: ListView.view.height
        text: model.displayName !== "" ? model.displayName : model.alias
        isReadonly: {
            if (model.isAdmin) return true
            if (root.chatContentModule.amIChatAdmin()) return false
            return index < root.chatContentModule.usersModule.model.count
        }
        icon: model.isAdmin ? "crown" : ""

        onClicked: root.entryRemoved(this)
    }

    QtObject {
        id: d

        function appendTemporaryModel(pubKey, displayName) {
            root.chatContentModule.usersModule.appendTemporaryModel(pubKey, displayName)
        }
        function removeFromTemporaryModel(pubKey) {
            root.chatContentModule.usersModule.removeFromTemporaryModel(pubKey)
        }
        function resetTemporaryModel() {
            root.chatContentModule.usersModule.resetTemporaryModel()
        }
        function updateGroupMembers() {
            root.chatContentModule.usersModule.updateGroupMembers()
        }
    }

    Component.onCompleted: {
        d.resetTemporaryModel()
    }
}
