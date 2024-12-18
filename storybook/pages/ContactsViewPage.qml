import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import shared.stores 1.0 as SharedStores
import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0
import mainui.adaptors 1.0

Item {
    id: root

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
        }
        utilsStore: SharedStores.UtilsStore {
            function getEmojiHash(publicKey) {
                if (publicKey === "")
                    return ""

                return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
            }
        }

        mutualContactsModel: adaptor.mutualContacts
        blockedContactsModel: adaptor.blockedContacts
        pendingContactsModel: adaptor.pendingContacts
        pendingReceivedContactsCount: adaptor.pendingReceivedRequestContacts.count
    }

    ContactsModelAdaptor {
        id: adaptor
        allContacts: SortFilterProxyModel {
            sourceModel: UsersModel {}
            proxyRoles: [
                FastExpressionRole {
                    function displayNameProxy(localNickname, ensName, displayName, aliasName) {
                        return ProfileUtils.displayName(localNickname, ensName, displayName, aliasName)
                    }

                    name: "preferredDisplayName"
                    expectedRoles: ["localNickname", "displayName", "ensName", "alias"]
                    expression: displayNameProxy(model.localNickname, model.ensName, model.displayName, model.alias)
                }
            ]
        }
    }
}

// category: Views
// status: good
