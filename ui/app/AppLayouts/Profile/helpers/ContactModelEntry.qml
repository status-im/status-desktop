import StatusQ.Core.Utils 0.1

import utils 1.0

import QtModelsToolkit 1.0

/**
  * Wrapper over generic ModelEntry to expose entries from model of contacts.
  */
QObject {
    id: root

    required property string publicKey
    required property var contactsModel

    readonly property ContactDetails contactDetails: ContactDetails {
        readonly property var entry: itemData.item

        publicKey: root.publicKey
        displayName: entry.displayName ?? ""
        ensName: entry.ensName ?? ""
        ensVerified: entry.isEnsVerified ?? false
        localNickname: entry.localNickname ?? ""
        alias: entry.alias ?? ""
        usesDefaultName: entry.usesDefaultName ?? false
        icon: entry.icon ?? ""
        colorId: entry.colorId ?? 0
        colorHash: entry.colorHash ?? []
        onlineStatus: entry.onlineStatus ?? Constants.onlineStatus.inactive
        isContact: entry.isContact ?? false
        isCurrentUser: entry.isCurrentUser ?? false
        isVerified: entry.isVerified ?? false
        isUntrustworthy: entry.isUntrustworthy ?? false
        isBlocked: entry.isBlocked ?? false
        contactRequestState: entry.contactRequest ?? Constants.ContactRequestState.None
        preferredDisplayName: entry.preferredDisplayName ?? ""
        lastUpdated: entry.lastUpdated ?? 0
        lastUpdatedLocally: entry.lastUpdatedLocally ?? 0
        thumbnailImage: entry.thumbnailImage ?? ""
        largeImage: entry.largeImage ?? ""
        isContactRequestReceived: entry.isContactRequestReceived ?? false
        isContactRequestSent: entry.isContactRequestSent ?? false
        removed: entry.isRemoved ?? false
        trustStatus: entry.trustStatus ?? Constants.trustStatus.unknown
        bio: entry.bio ?? ""

        // Backwards compatibility properties - Don't use in new code
        // TODO: #14965 - Try to remove these properties
        name: ensName
    }

    ModelEntry {
        id: itemData
        sourceModel: root.contactsModel
        key: "pubKey"
        value: root.publicKey
        cacheOnRemoval: true
    }
}
