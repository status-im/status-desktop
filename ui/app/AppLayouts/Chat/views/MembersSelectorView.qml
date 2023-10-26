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
        root.edit.clear()
        d.selectedMembers.clear()
    }

    onEntryAccepted: if (suggestionsDelegate) {
        if (root.limitReached)
            return
        if (d.addMember(suggestionsDelegate._pubKey, suggestionsDelegate.userName, suggestionsDelegate.nickName))
            root.edit.clear()
    }

    onEntryRemoved: if (delegate) {
        d.removeMember(delegate._pubKey)
    }

    edit.onTextChanged: {
        // When edited, give a small delay in case next character is printed soon
        contactLookupDelayTimer.start()
        root.pastedChatKey = ""
    }

    onTextPasted: (text) => {
        // When pated, process text immediately
        contactLookupDelayTimer.stop() // when pasting, textChanged is still emited first
        d.lookupContact(text)
    }

    model: SortFilterProxyModel {
        sourceModel: d.selectedMembers
    }

    delegate: StatusTagItem {
        readonly property string _pubKey: model.pubKey

        height: ListView.view.height
        text: root.tagText(model.localNickname, model.displayName, model.alias)

        onClosed: root.entryRemoved(this)
    }

    QtObject {
        id: d

        property ListModel selectedMembers: ListModel {}

        function lookupContact(value) {
            const urlContactData = Utils.parseContactUrl(value)
            if (urlContactData) {
                // Ignore all the data from the link, because it might be malformed.
                // Except for the publicKey.
                processContact(urlContactData.publicKey)
                return
            }

            value = Utils.dropUserLinkPrefix(value.trim())

            if (Utils.isChatKey(value)) {
                processContact(value)
                return
            }

            if (Utils.isValidEns(value)) {
                root.rootStore.contactsStore.resolveENS(value)
                return
            }

            root.suggestionsDialog.forceHide = false
        }

        function processContact(publicKey) {
            const contactDetails = Utils.getContactDetailsAsJson(publicKey, false)
            if (contactDetails.publicKey === "") {
                // not a valid key given
                root.suggestionsDialog.forceHide = false
                return
            }

            if (contactDetails.isContact) {
                // Is a contact, we add their name to the list
                root.pastedChatKey = contactDetails.publicKey
                root.suggestionsDialog.forceHide = false
                return
            }

            const hasPendingContactRequest = root.rootStore.contactsStore.hasPendingContactRequest(contactDetails.publicKey)

            if ((root.model.count === 0 && hasPendingContactRequest) ||
                    contactDetails.publicKey === root.rootStore.contactsStore.myPublicKey || contactDetails.isBlocked) {
                // List is empty and we have a contact request
                // OR it's our own chat key or a banned user
                // Then open the contact's profile popup
                Global.openProfilePopup(contactDetails.publicKey, null,
                                        popup => popup.closed.connect(root.rejected))
                return
            }

            if (root.model.count === 0 && !hasPendingContactRequest) {
                // List is empty and not a contact yet. Open the contact request popup
                Global.openContactRequestPopup(contactDetails.publicKey,
                                               popup => popup.closed.connect(root.rejected))
                return
            }

            root.suggestionsDialog.forceHide = false
        }

        function addMember(pubKey, displayName, localNickname) {
            for (let i = 0; i < d.selectedMembers.count; ++i) {
                if (d.selectedMembers.get(i).pubKey === pubKey)
                    return false
            }

            d.selectedMembers.append({
                                         "pubKey": pubKey,
                                         "displayName": displayName,
                                         "localNickname": localNickname
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
    }

    Timer {
        id: contactLookupDelayTimer
        repeat: false
        interval: 500
        onTriggered: {
            d.lookupContact(edit.text)
        }
    }

    Connections {
        enabled: root.visible
        target: root.rootStore.contactsStore.mainModuleInst
        function onResolvedENS(resolvedPubKey: string, resolvedAddress: string, uuid: string) {
            if (resolvedPubKey === "") {
                root.suggestionsDialog.forceHide = false
                return
            }
            d.processContact(resolvedPubKey)
        }
    }
}
