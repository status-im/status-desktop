import QtQuick

import StatusQ

import Models
import Storybook

import shared.stores as SharedStores
import AppLayouts.Profile.views
import AppLayouts.Profile.stores
import mainui.adaptors

Item {
    ContactsView {
        sectionTitle: "Contacts"
        anchors.fill: parent
        anchors.leftMargin: 64
        anchors.topMargin: 16
        contentWidth: 560

        contactsStore: ContactsStore {
            function joinPrivateChat(pubKey) {
                console.info("ContactsStore::joinPrivateChat", pubKey)
            }
            function acceptContactRequest(pubKey, contactRequestId) {
                console.info("ContactsStore::acceptContactRequest", pubKey, contactRequestId)
            }
            function dismissContactRequest(pubKey, contactRequestId) {
                console.info("ContactsStore::dismissContactRequest", pubKey, contactRequestId)
            }

            function resolveENS(value) {}

            signal resolvedENS(string resolvedPubKey, string resolvedAddress,
                               string uuid)
        }
        utilsStore: SharedStores.UtilsStore {
            function getEmojiHash(publicKey) {
                if (publicKey === "")
                    return ""

                return JSON.stringify(
                            ["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻",
                             "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
            }
        }

        mutualContactsModel: adaptor.mutualContacts
        blockedContactsModel: adaptor.blockedContacts
        pendingContactsModel: adaptor.pendingContacts
        dismissedReceivedRequestContactsModel: adaptor.dismissedReceivedRequestContactsModel
        pendingReceivedContactsCount: adaptor.pendingReceivedRequestContacts.count
    }

    ContactsModelAdaptor {
        id: adaptor

        allContacts: UsersModel {}
    }
}

// category: Views
// status: good
