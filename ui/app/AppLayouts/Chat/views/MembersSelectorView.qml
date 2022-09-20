import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml.Models 2.2

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "private"

import SortFilterProxyModel 0.2

MembersSelectorBase {
    id: root

    limitReached: model.count >= membersLimit - 1 // -1 because creator is not on the list of members when creating chat

    function cleanup() {
        root.edit.clear()
        d.selectedMembers.clear()
    }

    onEntryAccepted: {
        if (!root.limitReached) {
            d.addMember(suggestionsDelegate._pubKey, suggestionsDelegate.userName)
            root.edit.clear()
        }
    }

    onEntryRemoved: {
        d.removeMember(delegate._pubKey)
    }

    model: SortFilterProxyModel {
        sourceModel: d.selectedMembers
    }

    delegate: StatusTagItem {
        readonly property string _pubKey: model.pubKey
        height: ListView.view.height
        text: model.displayName

        onClicked: root.entryRemoved(this)
    }

    QtObject {
        id: d

        property ListModel selectedMembers: ListModel {}

        function addMember(pubKey, displayName) {
            d.selectedMembers.append({
                                         "pubKey": pubKey,
                                         "displayName": displayName
                                     })
        }
        function removeMember(pubKey) {
            for(var i = 0; i < d.selectedMembers.count; i++) {
                const obj = d.selectedMembers.get(i)
                if(obj.pubKey === pubKey) {
                    d.selectedMembers.remove(i)
                    return
                }
            }
        }
    }
}
