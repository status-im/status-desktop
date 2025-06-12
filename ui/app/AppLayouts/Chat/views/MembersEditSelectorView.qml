import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.stores 1.0

import utils 1.0

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

import "private"

MembersSelectorBase {
    id: root

    property var usersModel // Source model
    property bool amIChatAdmin

    signal groupMembersUpdateRequested(string membersPubKeysList)

    QtObject {
        id: d

        property ListModel tempUsersList: ListModel {}

        property string originalPubKeysList: ""
        property string currentPubKeysList: ""

        readonly property bool dirty: originalPubKeysList !== currentPubKeysList

        function calculatePublicKeysList(model) {
            const keys = ModelUtils.modelToFlatArray(model, "pubKey")
            keys.sort()
            return keys.join(",")
        }

        function resetTempUsersList() {
            tempUsersList.clear()
            const items = []
            for (let i = 0; i < root.usersModel.ModelCount.count; ++i) {
                const item = ModelUtils.get(root.usersModel, i)
                items.push({
                               pubKey: item.pubKey,
                               preferredDisplayName: item.preferredDisplayName,
                               memberRole: item.memberRole ?? Constants.memberRole.none
                           })
            }
            tempUsersList.append(items)
            originalPubKeysList = calculatePublicKeysList(tempUsersList)
            currentPubKeysList = originalPubKeysList
        }
    }

    dirty: d.dirty

    model: SortFilterProxyModel {
        sourceModel: d.tempUsersList
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
            return index < root.usersModel.ModelCount.count
        }
        icon: model.memberRole === Constants.memberRole.owner ? "crown" : ""

        onClosed: root.entryRemoved(this)
    }

    onRejected: {
        d.resetTempUsersList()
    }

    onConfirmed: {
        if (d.dirty) {
            groupMembersUpdateRequested(d.currentPubKeysList)
        }
        d.resetTempUsersList()
    }

    onEntryAccepted: {
        if (suggestionsDelegate && !root.limitReached) {
            const pubKey = suggestionsDelegate._pubKey
            const exists = ModelUtils.contains(d.tempUsersList, "pubKey", pubKey)
            if (!exists) {
                d.tempUsersList.append({
                                           pubKey: pubKey,
                                           preferredDisplayName: suggestionsDelegate.userName,
                                           memberRole: suggestionsDelegate.memberRole ?? Constants.memberRole.none
                                       })
                d.currentPubKeysList = d.calculatePublicKeysList(d.tempUsersList)
            }
            root.edit.clear()
        }
    }

    onEntryRemoved: {
        if (delegate && !delegate.isReadonly) {
            const pubKey = delegate._pubKey
            const index = ModelUtils.indexOf(d.tempUsersList, "pubKey", pubKey)
            if (index >= 0) {
                d.tempUsersList.remove(index)
                d.currentPubKeysList = d.calculatePublicKeysList(d.tempUsersList)
            }
        }
    }

    Component.onCompleted: {
        d.resetTempUsersList()
    }
}
