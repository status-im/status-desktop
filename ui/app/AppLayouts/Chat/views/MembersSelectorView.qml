import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml.Models 2.2

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "private"

import utils 1.0

import SortFilterProxyModel 0.2

MembersSelectorBase {
    id: root

    limitReached: model.count >= membersLimit - 1 // -1 because creator is not on the list of members when creating chat

    function cleanup() {
        d.cleanup()
    }

    onEntryAccepted: {
        if (root.limitReached)
            return
        if (d.addMember(suggestionsDelegate._pubKey, suggestionsDelegate.userName))
            root.edit.clear()
    }

    onEntryRemoved: {
        d.removeMember(delegate._pubKey)
    }

    onTextPasted: {
        d.lookupContact(text);
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

        property ListModel selectedMembers: ListModel {
            Component.onCompleted: d.addOurselvesToModel()
        }

        function lookupContact(value) {
            if (value.startsWith(Constants.userLinkPrefix))
                value = value.slice(Constants.userLinkPrefix.length)
            root.rootStore.contactsStore.resolveENS(value)
        }

        function addMember(pubKey, displayName) {
            for (let i = 0; i < d.selectedMembers.count; ++i) {
                if (d.selectedMembers.get(i).pubKey === pubKey)
                    return false
            }

            d.selectedMembers.append({
                                         "pubKey": pubKey,
                                         "displayName": displayName
                                     })
            return true
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

        function addOurselvesToModel() {
            d.selectedMembers.append({
                                         "pubKey": userProfile.pubKey,
                                         "displayName": userProfile.name
                                     })
        }

        function cleanup() {
            root.edit.clear()
            d.selectedMembers.clear()
            d.addOurselvesToModel()
        }
    }

    Connections {
        enabled: root.visible
        target: root.rootStore.contactsStore.mainModuleInst
        onResolvedENS: {

            if (resolvedPubKey === "")
                return

            const contactDetails = Utils.getContactDetailsAsJson(resolvedPubKey)

            if (contactDetails.publicKey === root.rootStore.contactsStore.myPublicKey)
                return;

            if (contactDetails.isBlocked)
                return;

            if (contactDetails.isContact) {
                if (d.addMember(contactDetails.publicKey, contactDetails.displayName))
                    root.cleanup()
                return
            }

            if (root.model.count === 0) {
                const popup = Global.openContactRequestPopup(contactDetails.publicKey)
                popup.closed.connect(root.rejected)
                return
            }
        }
    }
}
