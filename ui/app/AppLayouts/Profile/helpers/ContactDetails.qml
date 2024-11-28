import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Profile.stores 1.0

import utils 1.0

QObject {
    id: root

    required property ContactsStore contactsStore
    required property ProfileStore profileStore
    required property string publicKey

    readonly property alias loading: d.loading

    // model properties
    readonly property string displayName: d.contactDetails.displayName ?? ""
    readonly property string ensName: d.contactDetails.ensName ?? ""
    readonly property bool ensVerified: d.contactDetails.isEnsVerified ?? false
    readonly property string localNickname: d.contactDetails.localNickname ?? ""
    readonly property string alias: d.contactDetails.alias ?? ""
    readonly property string icon: d.contactDetails.icon ?? ""
    readonly property int colorId: d.contactDetails.colorId ?? 0
    readonly property var colorHash: d.contactDetails.colorHash ?? []
    readonly property int onlineStatus: d.contactDetails.onlineStatus ?? Constants.onlineStatus.inactive
    readonly property bool isContact: d.contactDetails.isContact ?? false
    readonly property bool isCurrentUser: d.contactDetails.isCurrentUser ?? false
    readonly property bool isVerified: d.contactDetails.isVerified ?? false
    readonly property bool isUntrustworthy: d.contactDetails.isUntrustworthy ?? false
    readonly property bool isBlocked: d.contactDetails.isBlocked ?? false
    readonly property int contactRequestState: d.contactDetails.contactRequest ?? Constants.ContactRequestState.None
    readonly property string preferredDisplayName: d.contactDetails.preferredDisplayName ?? ""
    readonly property int lastUpdated: d.contactDetails.lastUpdated ?? 0
    readonly property int lastUpdatedLocally: d.contactDetails.lastUpdatedLocally ?? 0
    readonly property string thumbnailImage: d.contactDetails.thumbnailImage ?? ""
    readonly property string largeImage: d.contactDetails.largeImage ?? ""
    readonly property bool isContactRequestReceived: d.contactDetails.isContactRequestReceived ?? false
    readonly property bool isContactRequestSent: d.contactDetails.isContactRequestSent ?? false
    readonly property bool removed: d.contactDetails.isRemoved ?? false
    readonly property int trustStatus: d.contactDetails.trustStatus ?? Constants.trustStatus.unknown
    readonly property string bio: d.contactDetails.bio ?? ""

    // Backwards compatibility properties - Don't use in new code
    // TODO: #14965 - Try to remove these properties
    readonly property string name: ensName

    // Extra properties provided by getContactDetailsAsJson, not available in the model
    // TODO: #14964 - Review all the model rolenames and fill the rest of the properties with data from the model
    //readonly property var socialLinks: d.contactDetails.socialLinks ?? []

    ModelEntry {
        id: itemData
        sourceModel: root.publicKey !== "" && !d.isMe ? contactsStore.contactsModel : null
        key: "pubKey"
        value: root.publicKey
        cacheOnRemoval: true
    }

    QObject {
        id: d
        readonly property bool loading: !itemData.available && !isMe
        onLoadingChanged: {
            if (loading) {
                contactsStore.requestContactInfo(root.publicKey)
            }
        }

        readonly property bool isMe: root.contactsStore.myPublicKey === root.publicKey
        readonly property var ownProfile: QObject {
            readonly property string displayName: root.profileStore.displayName
            readonly property string ensName: root.profileStore.name
            readonly property bool isEnsVerified: root.profileStore.name !== "" && Utils.isValidEns(root.profileStore.name)
            readonly property string localNickname: ""
            readonly property string preferredDisplayName: root.profileStore.preferredDisplayName
            readonly property string name: preferredDisplayName
            readonly property string alias: root.profileStore.username
            readonly property string icon: root.profileStore.icon
            readonly property int colorId: root.profileStore.colorId
            readonly property var colorHash: root.profileStore.colorHash
            readonly property int onlineStatus: root.profileStore.currentUserStatus
            readonly property bool isContact: false
            readonly property bool isCurrentUser: true
            readonly property bool isVerified: false
            readonly property bool isUntrustworthy: false
            readonly property bool isBlocked: false
            readonly property int contactRequestState: Constants.ContactRequestState.None
            readonly property int lastUpdated: 0
            readonly property int lastUpdatedLocally: 0
            readonly property string thumbnailImage: root.profileStore.thumbnailImage
            readonly property string largeImage: root.profileStore.largeImage
            readonly property bool isContactRequestReceived: Constants.ContactRequestState.None
            readonly property bool isContactRequestSent: Constants.ContactRequestState.None
            readonly property bool removed: false
            readonly property int trustStatus: Constants.trustStatus.unknown
            readonly property string bio: root.profileStore.bio
        }

        readonly property var contactDetails: !isMe ? itemData.item : ownProfile
    }
}
