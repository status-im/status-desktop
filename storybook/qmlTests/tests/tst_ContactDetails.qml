import QtQuick 2.15
import QtTest 1.15
import QtQml 2.15

import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.stores 1.0

Item {
    id: root

    Component {
        id: testComponent
        ContactDetails {
            id: contactDetails
        }
    }

    Component {
        id: failingTestComponent
        ContactDetails {
            id: contactDetails
        }
    }

    Component {
        id: contactsStore
        ContactsStore {
            readonly property string myPublicKey: "0x123"
            readonly property ListModel contactsModel: ListModel { id: myContactsModel }
            property var requestContactInfo: requestContactInfoCall
            function requestContactInfoCall(pubKey) {
                myContactsModel.append({
                    pubKey: pubKey,
                    displayName: "displayName",
                    ensName: "ensName",
                    isEnsVerified: true,
                    localNickname: "localNickname",
                    alias: "alias",
                    icon: "icon",
                    colorId: 1,
                    colorHash: [],
                    onlineStatus: 1,
                    isContact: true,
                    isCurrentUser: false,
                    isVerified: true,
                    isUntrustworthy: false,
                    isBlocked: false,
                    contactRequest: 3,
                    preferredDisplayName: "preferredDisplayName",
                    lastUpdated: 1234567890,
                    lastUpdatedLocally: 1234567890,
                    thumbnailImage: "thumbnailImage",
                    largeImage: "largeImage",
                    isContactRequestReceived: false,
                    isContactRequestSent: false,
                    isRemoved: false,
                    trustStatus: 1,
                    bio: "bio"
                })
            }
        }
    }

    Component {
        id: profileStore
        ProfileStore {
            id: profileStoreMock
            readonly property string displayName: "myDisplayName"
            readonly property string name: "myEnsName"
            readonly property string username: "myUsername"
            readonly property string icon: "myIcon"
            readonly property int colorId: 1
            readonly property var colorHash: {1}
            readonly property int currentUserStatus: 1
            readonly property string preferredDisplayName: "myPreferredDisplayName"
            readonly property string thumbnailImage: "myThumbnailImage"
            readonly property string largeImage: "myLargeImage"
            readonly property string bio: "myBio"
        }
    }

    TestCase {
        name: "ContactDetailsTest"
        function test_initialization() {
            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: createTemporaryObject(contactsStore, root),
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: ""
            })

            verify(!!contactDetails, "Expected the contact details to initialize")
        }

        function test_initializationOwnProfile() {
            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: createTemporaryObject(contactsStore, root),
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x123"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x123", "Expected the public key to be set")
            compare(contactDetails.contactsStore.myPublicKey,"0x123", "Expected the contacts store to be set")
            compare(contactDetails.profileStore.displayName,"myDisplayName", "Expected the profile store to be set")
            compare(contactDetails.displayName, contactDetails.profileStore.displayName, "Expected the display name to be set")
            compare(contactDetails.ensName, contactDetails.profileStore.name, "Expected the ens name to be set")
            compare(contactDetails.ensVerified, false, "Expected the ensVerified to be set")
            compare(contactDetails.localNickname, "", "Expected the local nickname to be empty")
            compare(contactDetails.alias, contactDetails.profileStore.username, "Expected the alias to be set")
            compare(contactDetails.icon, contactDetails.profileStore.icon, "Expected the icon to be set")
            compare(contactDetails.colorId, contactDetails.profileStore.colorId, "Expected the color id to be set")
            compare(contactDetails.colorHash, contactDetails.profileStore.colorHash, "Expected the color hash to be empty")
            compare(contactDetails.onlineStatus, contactDetails.profileStore.currentUserStatus, "Expected the online status to be set")
            compare(contactDetails.thumbnailImage, contactDetails.profileStore.thumbnailImage, "Expected the is contact flag to be set")
            compare(contactDetails.largeImage, contactDetails.profileStore.largeImage, "Expected the is contact flag to be set")
            compare(contactDetails.bio, contactDetails.profileStore.bio, "Expected the is contact flag to be set")
            compare(contactDetails.isContact, false, "Expected the is contact flag to be set")
            compare(contactDetails.isCurrentUser, true, "Expected the is contact flag to be set")
        }

        function test_initializationWithContact() {
            const contactsStoreMock = createTemporaryObject(contactsStore, root)
            contactsStoreMock.requestContactInfo("0x321") //appending new contact to the model

            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: contactsStoreMock,
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x321"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x321", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be set")
            compare(contactDetails.localNickname, "localNickname", "Expected the local nickname to be set")
            compare(contactDetails.alias, "alias", "Expected the alias to be set")
            compare(contactDetails.icon, "icon", "Expected the icon to be set")
            compare(contactDetails.colorId, 1, "Expected the color id to be set")
            compare(contactDetails.onlineStatus, 1, "Expected the online status to be set")
            compare(contactDetails.thumbnailImage, "thumbnailImage", "Expected the thumbnailImage to be set")
            compare(contactDetails.largeImage, "largeImage", "Expected the largeImage to be set")
            compare(contactDetails.bio, "bio", "Expected the bio to be set")
            compare(contactDetails.isContact, true, "Expected the is contact flag to be set")
            compare(contactDetails.isCurrentUser, false, "Expected the isCurrentUser flag to be set")
            compare(contactDetails.isVerified, true, "Expected the isVerified flag to be set")
            compare(contactDetails.isUntrustworthy, false, "Expected the isUntrustworthy flag to be set")
            compare(contactDetails.isBlocked, false, "Expected the isBlocked flag to be set")
            compare(contactDetails.contactRequestState, 3, "Expected the contactRequestState flag to be set")
            compare(contactDetails.preferredDisplayName, "preferredDisplayName", "Expected the preferredDisplayName to be set")
            compare(contactDetails.lastUpdated, 1234567890, "Expected the lastUpdated to be set")
            compare(contactDetails.lastUpdatedLocally, 1234567890, "Expected the lastUpdatedLocally to be set")
            compare(contactDetails.isContactRequestReceived, false, "Expected the isContactRequestReceived flag to be set")
            compare(contactDetails.isContactRequestSent, false, "Expected the isContactRequestSent flag to be set")
            compare(contactDetails.removed, false, "Expected the removed flag to be set")
            compare(contactDetails.trustStatus, 1, "Expected the trustStatus flag to be set")
        }

        function test_initFails() {
            ignoreWarning(new RegExp("Required property publicKey was not initialized"))
            ignoreWarning(new RegExp("Required property contactsStore was not initialized"))
            ignoreWarning(new RegExp("Required property profileStore was not initialized"))

            const contactDetails = createTemporaryObject(failingTestComponent, root)
            verify(!contactDetails, "Expected the contact details to fail to initialize")
        }

        function test_initWithEmptyContacts() {
            const contactsStoreMock = createTemporaryObject(contactsStore, root)
            let requestContactInfoCallCount = 0
            contactsStoreMock.requestContactInfo = function(pubKey) {
                requestContactInfoCallCount++
            }
            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: contactsStoreMock,
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x1234"
            })

            compare(requestContactInfoCallCount, 1, "Expected the requestContactInfo to be called")
            compare(contactDetails.loading, true, "Expected the loading flag to be true")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")

            //add the contact
            contactsStoreMock.requestContactInfo = contactsStoreMock.requestContactInfoCall
            contactsStoreMock.requestContactInfo("0x1234")

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be set")
        }

        function test_contactRemovedFromModel() {
            const contactsStoreMock = createTemporaryObject(contactsStore, root)
            contactsStoreMock.requestContactInfo("0x1234") //appending new contact to the model

            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: contactsStoreMock,
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x1234"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be set")

            // removing from model should not clear the contact details
            contactsStoreMock.contactsModel.remove(0)

            compare(contactDetails.loading, false, "Expected the loading flag to be true")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be empty")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be empty")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be false")
        }

        function test_liveUpdate() {
            const contactsStoreMock = createTemporaryObject(contactsStore, root)
            contactsStoreMock.requestContactInfo("0x1234") //appending new contact to the model

            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: contactsStoreMock,
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x1234"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be set")

            // updating the contact should update the contact details
            contactsStoreMock.contactsModel.set(0, {
                pubKey: "0x1234",
                displayName: "newDisplayName",
                ensName: "newEnsName",
                isEnsVerified: false,
                localNickname: "newLocalNickname",
                alias: "newAlias",
                icon: "newIcon",
                colorId: 2,
                colorHash: [],
                onlineStatus: 2,
                isContact: false,
                isCurrentUser: true,
                isVerified: false,
                isUntrustworthy: true,
                isBlocked: true,
                contactRequest: 2,
                preferredDisplayName: "newPreferredDisplayName",
                lastUpdated: 1234567891,
                lastUpdatedLocally: 1234567891,
                thumbnailImage: "newThumbnailImage",
                largeImage: "newLargeImage",
                isContactRequestReceived: true,
                isContactRequestSent: true,
                isRemoved: true,
                trustStatus: 2,
                bio: "newBio"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x1234", "Expected the public key to be set")
            compare(contactDetails.displayName, "newDisplayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "newEnsName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, false, "Expected the ensVerified to be set")
            compare(contactDetails.localNickname, "newLocalNickname", "Expected the local nickname to be set")
            compare(contactDetails.alias, "newAlias", "Expected the alias to be set")
            compare(contactDetails.icon, "newIcon", "Expected the icon to be set")
            compare(contactDetails.colorId, 2, "Expected the color id to be set")
            compare(contactDetails.onlineStatus, 2, "Expected the online status to be set")
            compare(contactDetails.thumbnailImage, "newThumbnailImage", "Expected the thumbnailImage to be set")
            compare(contactDetails.largeImage, "newLargeImage", "Expected the largeImage to be set")
            compare(contactDetails.bio, "newBio", "Expected the bio to be set")
            compare(contactDetails.isContact, false, "Expected the is contact flag to be set")
            compare(contactDetails.isCurrentUser, true, "Expected the isCurrentUser flag to be set")
            compare(contactDetails.isVerified, false, "Expected the isVerified flag to be set")
            compare(contactDetails.isUntrustworthy, true, "Expected the isUntrustworthy flag to be set")
            compare(contactDetails.isBlocked, true, "Expected the isBlocked flag to be set")
            compare(contactDetails.contactRequestState, 2, "Expected the contactRequestState flag to be set")
            compare(contactDetails.preferredDisplayName, "newPreferredDisplayName", "Expected the preferredDisplayName to be set")
            compare(contactDetails.lastUpdated, 1234567891, "Expected the lastUpdated to be set")
            compare(contactDetails.lastUpdatedLocally, 1234567891, "Expected the lastUpdatedLocally to be set")
            compare(contactDetails.isContactRequestReceived, true, "Expected the isContactRequestReceived flag to be set")
            compare(contactDetails.isContactRequestSent, true, "Expected the isContactRequestSent flag to be set")
            compare(contactDetails.removed, true, "Expected the removed flag to be set")
            compare(contactDetails.trustStatus, 2, "Expected the trustStatus flag to be set")
        }

        function test_changingPublicKeyFromOwnToContact() {
            const contactsStoreMock = createTemporaryObject(contactsStore, root)
            const contactDetails = createTemporaryObject(testComponent, root, {
                contactsStore: contactsStoreMock,
                profileStore: createTemporaryObject(profileStore, root),
                publicKey: "0x123"
            })

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x123", "Expected the public key to be set")
            compare(contactDetails.contactsStore.myPublicKey,"0x123", "Expected the contacts store to be set")
            compare(contactDetails.profileStore.displayName,"myDisplayName", "Expected the profile store to be set")
            compare(contactDetails.displayName, contactDetails.profileStore.displayName, "Expected the display name to be set")
            compare(contactDetails.ensName, contactDetails.profileStore.name, "Expected the ens name to be set")

            contactDetails.publicKey = "0x321"

            compare(contactDetails.loading, false, "Expected the loading flag to be false")
            compare(contactDetails.publicKey,"0x321", "Expected the public key to be set")
            compare(contactDetails.displayName, "displayName", "Expected the display name to be set")
            compare(contactDetails.ensName, "ensName", "Expected the ens name to be set")
            compare(contactDetails.ensVerified, true, "Expected the ensVerified to be set")
            compare(contactDetails.localNickname, "localNickname", "Expected the local nickname to be set")
        }
    }
}
