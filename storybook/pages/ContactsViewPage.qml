import QtQuick 2.15

import StatusQ 0.1

import Models 1.0
import Storybook 1.0

import shared.stores 1.0 as SharedStores
import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0
import mainui.adaptors 1.0

Item {
    ContactsView {
        sectionTitle: "Contacts"
        anchors.fill: parent
        anchors.leftMargin: 64
        anchors.topMargin: 16
        contentWidth: 560

        contactsStore: ContactsStore {
            function joinPrivateChat(pubKey) {}
            function acceptContactRequest(pubKey, contactRequestId) {}
            function dismissContactRequest(pubKey, contactRequestId) {}

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
        pendingReceivedContactsCount: adaptor.pendingReceivedRequestContacts.count
    }

    ContactsModelAdaptor {
        id: adaptor

        allContacts: UsersModel {}
    }
}

// category: Views
// status: good
