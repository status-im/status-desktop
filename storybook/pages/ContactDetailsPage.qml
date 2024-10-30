import QtTest 1.15

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import StatusQ.Core.Utils 0.1
import Models 1.0

import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.stores 1.0

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        contentItem: ColumnLayout {
            clip: true
            spacing: 5
            Label {
                Layout.fillWidth: true
                text: "publicKey: " + contactDetails.publicKey
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                text: "loading: " + contactDetails.loading
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                text: "displayName: " + contactDetails.displayName
            }
            Label {
                Layout.fillWidth: true
                text: "ensName: " + contactDetails.ensName
            }
            Label {
                Layout.fillWidth: true
                text: "ensVerified: " + contactDetails.ensVerified
            }
            Label {
                Layout.fillWidth: true
                text: "localNickname: " + contactDetails.localNickname
            }
            Label {
                Layout.fillWidth: true
                text: "alias: " + contactDetails.alias
            }
            Label {
                Layout.fillWidth: true
                text: "icon: " + contactDetails.icon
            }
            Label {
                Layout.fillWidth: true
                text: "colorId: " + contactDetails.colorId
            }
            Label {
                Layout.fillWidth: true
                text: "colorHash: " + contactDetails.colorHash
            }
            Label {
                Layout.fillWidth: true
                text: "onlineStatus: " + contactDetails.onlineStatus
            }
            Label {
                Layout.fillWidth: true
                text: "isContact: " + contactDetails.isContact
            }
            Label {
                Layout.fillWidth: true
                text: "isCurrentUser: " + contactDetails.isCurrentUser
            }
            Label {
                Layout.fillWidth: true
                text: "isVerified: " + contactDetails.isVerified
            }
            Label {
                Layout.fillWidth: true
                text: "isUntrustworthy: " + contactDetails.isUntrustworthy
            }
            Label {
                Layout.fillWidth: true
                text: "isBlocked: " + contactDetails.isBlocked
            }
            Label {
                Layout.fillWidth: true
                text: "contactRequestState: " + contactDetails.contactRequestState
            }

            Pane {
                contentItem: RowLayout {
                    ComboBox {
                        id: pubKeySelector
                        model: [...ModelUtils.modelToFlatArray(myContactsModel, "pubKey"), "myPubKey", "none"]
                        ModelChangeTracker {
                            id: modelChangeTracker
                            model: myContactsModel
                            onRevisionChanged: {
                                pubKeySelector.model = [...ModelUtils.modelToFlatArray(myContactsModel, "pubKey"), "myPubKey", "none"]
                            }
                        }
                    }
                }
            }
        }
    }

    Pane {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 500
        contentItem: UsersModelEditor {
            id: myContactsModelEditor
            model: myContactsModel

            onRemoveClicked: (index) => {
                myContactsModel.remove(index, 1)
            }
            onRemoveAllClicked: () => {
                myContactsModel.clear()
            }
            onAddClicked: () => {
                myContactsModel.append(getNewUser(myContactsModel.count))
            }
        }
    }

    UsersModel {
        id: myContactsModel
    }

    ContactsStore {
        id: contactsStoreMock
        readonly property string myPublicKey: "0x123"
        readonly property UsersModel contactsModel: myContactsModel
        function requestContactInfo(pubKey) {
            myContactsModel.append({
                pubKey: pubKey,
                displayName: "displayName",
                ensName: "ensName",
                ensVerified: true,
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
                contactRequestState: 3,
                preferredDisplayName: "preferredDisplayName",
                lastUpdated: 1234567890,
                lastUpdatedLocally: 1234567890,
                thumbnailImage: "thumbnailImage",
                largeImage: "largeImage",
                isContactRequestReceived: false,
                isContactRequestSent: false,
                removed: false,
                trustStatus: 1,
                bio: "bio"
            })
        }
    }

    ProfileStore {
        id: profileStoreMock
        readonly property string displayName: "myDisplayName"
        readonly property string name: "myEnsName"
        readonly property string username: "myUsername"
        readonly property string icon: "myIcon"
        readonly property int colorId: 1
        readonly property var colorHash: {}
        readonly property int currentUserStatus: 1
        readonly property string preferredDisplayName: "myPreferredDisplayName"
        readonly property string thumbnailImage: "myThumbnailImage"
        readonly property string largeImage: "myLargeImage"
        readonly property string bio: "myBio"
    }

    ContactDetails {
        id: contactDetails
        contactsStore: contactsStoreMock
        profileStore: profileStoreMock
        publicKey: pubKeySelector.currentText === "myPubKey" ? "0x123" : pubKeySelector.currentText
    }
}
// category: Contacts

// Page is working in general but throwing multiple "Cannot read property" when changing id via combo box
// status: decent
