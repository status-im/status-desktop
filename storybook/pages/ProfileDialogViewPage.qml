import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.views 1.0
import shared.stores 1.0
import mainui 1.0

import StatusQ 0.1

import AppLayouts.Wallet.stores 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    // globalUtilsInst mock
    QtObject {
        function getEmojiHashAsJson(publicKey) {
            return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
        }
        function getColorId(publicKey) { return colorId.value }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey, skipEnsVerification=false) {
            if (skipEnsVerification)
                return
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

        function addTimestampToURL(url) {
            return url
        }

        function copyImageToClipboardByUrl(data) {
            logs.logEvent("Utils::copyImageToClipboardByUrl", ["data"], arguments)
        }

        function downloadImageByUrl(url, path) {
            logs.logEvent("Utils::downloadImageByUrl", ["url", "path"], arguments)
        }

        function isAlias(name)  {
            return false
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true

        }
        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    // mainModuleInst mock
    QtObject {
        function isEnsVerified(publicKey) {
            return ensVerified.checked
        }

        function getContactDetailsAsJson(publicKey, getVerificationRequest=true, getOnlineStatus=false, includeDetails=false) {
            return JSON.stringify({ displayName: displayName.text,
                                      optionalName: "",
                                      displayIcon: "",
                                      publicKey: publicKey,
                                      name: name.text,
                                      ensVerified: ensVerified.checked,
                                      alias: "Mock Alias Triplet",
                                      lastUpdated: Date.now(),
                                      lastUpdatedLocally: Date.now(),
                                      localNickname: localNickname.text,
                                      thumbnailImage: "",
                                      largeImage: userImage.checked ? Style.png("status-logo") : "",
                                      isContact: ctrlIsContact.checked,
                                      isBlocked: ctrlIsBlocked.checked,
                                      isSyncing: false,
                                      trustStatus: ctrlTrustStatus.currentValue,
                                      verificationStatus: ctrlVerificationStatus.currentValue,
                                      incomingVerificationStatus: ctrlIncomingVerificationStatus.currentValue,
                                      contactRequestState: ctrlContactRequestState.currentValue,
                                      bio: bio.text,
                                      socialLinks: JSON.stringify
                                                   ([{
                                                         text: "__twitter",
                                                         url: "https://twitter.com/ethstatus",
                                                         icon: "twitter"
                                                     },
                                                     {
                                                         text: "__github",
                                                         url: "https://github.com/status-im",
                                                         icon: "github"
                                                     }]),
                                      onlineStatus: ctrlOnlineStatus.currentValue
                                  })
        }
        Component.onCompleted: {
            Utils.mainModuleInst = this
            root.mainModuleReady = true
        }
        Component.onDestruction: {
            root.mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Component.onCompleted: {
        Global.userProfile = {
            name: "Anna",
            pubKey: "Oxdeadbeef",
            icon: ModelsData.collectibles.cryptoPunks
        }
    }

    Logs { id: logs }

    Popups {
        popupParent: root
        rootStore: QtObject {
            property var contactStore: QtObject {
                property var contactsModule: null

                function changeContactNickname(publicKey, newNickname, displayName, isEdit) {
                    logs.logEvent("rootStore::contactsStore::changeContactNickname", ["publicKey", "newNickname", "displayName", "isEdit"], arguments)
                    localNickname.text = newNickname
                }

                function blockContact(publicKey) {
                    logs.logEvent("rootStore::contactStore::blockContact", ["publicKey"], arguments)
                    ctrlIsBlocked.checked = true
                }

                function unblockContact(publicKey) {
                    logs.logEvent("rootStore::contactStore::unblockContact", ["publicKey"], arguments)
                    ctrlIsBlocked.checked = false
                }

                function sendContactRequest(publicKey, message) {
                    logs.logEvent("rootStore::contactStore::sendContactRequest", ["publicKey", "message"], arguments)
                    ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.Sent)
                }

                function acceptContactRequest(publicKey, contactRequestId) {
                    logs.logEvent("rootStore::contactStore::acceptContactRequest", ["publicKey, contactRequestId"], arguments)
                    ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.Mutual)
                }

                function getLatestContactRequestForContactAsJson(pubKey) {
                    logs.logEvent("rootStore::contactStore::getLatestContactRequestForContactAsJson", ["pubKey"], arguments)
                    return {
                        id: "123456789",
                        from: pubKey,
                        clock: Date.now(),
                        text: "Hey Jo, it’s Alex here, we met at devcon last week!",
                        contactRequestState: Constants.ContactRequestState.Received
                    }
                }

                function sendVerificationRequest(publicKey, challenge) {
                    logs.logEvent("rootStore::contactStore::sendVerificationRequest", ["publicKey", "challenge"], arguments)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                }

                function markUntrustworthy(publicKey) {
                    logs.logEvent("rootStore::contactStore::markUntrustworthy", ["publicKey"], arguments)
                    ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.untrustworthy)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                }

                function markAsTrusted(publicKey) {
                    logs.logEvent("rootStore::contactStore::markAsTrusted", ["publicKey"], arguments)
                    ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.trusted)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.trusted)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.trusted)
                }

                function removeContact(publicKey) {
                    logs.logEvent("rootStore::contactStore::removeContact", ["publicKey"], arguments)
                    ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.None)
                    ctrlIsContact.checked = false
                }

                function verifiedTrusted(publicKey) {
                    logs.logEvent("rootStore::contactStore::verifiedTrusted", ["publicKey"], arguments)
                    ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.trusted)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.trusted)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.trusted)
                }

                function removeTrustStatus(publicKey) {
                    logs.logEvent("rootStore::contactStore::removeTrustStatus", ["publicKey"], arguments)
                    ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.unknown)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                }

                function cancelVerificationRequest(pubKey) {
                    logs.logEvent("rootStore::contactStore::cancelVerificationRequest", ["pubKey"], arguments)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                }

                function declineVerificationRequest(pubKey) {
                    logs.logEvent("rootStore::contactStore::declineVerificationRequest", ["pubKey"], arguments)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                }

                function acceptVerificationRequest(pubKey, response) {
                    logs.logEvent("rootStore::contactStore::acceptVerificationRequest", ["pubKey"], arguments)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                }

                function verifiedUntrustworthy(pubKey) {
                    logs.logEvent("rootStore::contactStore::verifiedUntrustworthy", ["pubKey"], arguments)
                    ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                    ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.untrustworthy)
                }

                function getSentVerificationDetailsAsJson(pubKey) {
                    return {
                        requestStatus: ctrlVerificationStatus.currentValue,
                        challenge: "The real Alex would know this 100%! What’s my favourite colour?",
                        response: ctrlIncomingVerificationStatus.currentValue === Constants.verificationStatus.verified ? "Yellow!" : "",
                        displayName: ProfileUtils.displayName(localNickname.text, name.text, displayName.text),
                        icon: Style.png("status-logo"),
                        requestedAt: Date.now() - 86400000,
                        repliedAt: Date.now()
                    }
                }

                function getVerificationDetailsFromAsJson(pubKey) {
                    return {
                        from: "0xdeadbeef",
                        challenge: "The real Alex would know this 100%! What’s my favourite colour?",
                        response: "",
                        requestedAt: Date.now() - 86400000,
                    }
                }
            }
        }
        communityTokensStore: CommunityTokensStore {}
    }

    WalletAssetsStore {
        id: assetsStore
        assetsWithFilteredBalances: groupedAccountsAssetsModel
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            ScrollView {
                width: parent.width
                height: parent.height
                clip: true

                Loader {
                    active: root.globalUtilsReady && root.mainModuleReady
                    width: parent.availableWidth
                    height: parent.availableHeight

                    sourceComponent: ProfileDialogView {
                        implicitWidth: 640

                        readOnly: ctrlReadOnly.checked

                        publicKey: switchOwnProfile.checked ? "0xdeadbeef" : "0xrandomguy"

                        onCloseRequested: logs.logEvent("closeRequested()")

                        sendToAccountEnabled: true

                        showcaseCommunitiesModel: CommunitiesModel {}
                        showcaseAccountsModel: WalletAccountsModel {}
                        showcaseCollectiblesModel: ManageCollectiblesModel {}
                        showcaseSocialLinksModel: assetsStore.groupedAccountAssetsModel
                        // TODO: showcaseAssetsModel

                        profileStore: QtObject {
                            readonly property string pubkey: "0xdeadbeef"
                            readonly property string ensName: name.text

                            function getQrCodeSource() {
                                return "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"
                            }
                            function copyToClipboard(text) {
                                logs.logEvent("profileStore::copyToClipboard", ["text"], arguments)
                            }
                        }

                        contactsStore: QtObject {
                            readonly property string myPublicKey: "0xdeadbeef"

                            function joinPrivateChat(publicKey) {
                                logs.logEvent("contactsStore::joinPrivateChat", ["publicKey"], arguments)
                            }

                            function markUntrustworthy(publicKey) {
                                logs.logEvent("contactsStore::markUntrustworthy", ["publicKey"], arguments)
                                ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.untrustworthy)
                            }

                            function removeContact(publicKey) {
                                logs.logEvent("contactsStore::removeContact", ["publicKey"], arguments)
                                ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.None)
                                ctrlIsContact.checked = false
                            }

                            function acceptContactRequest(publicKey, contactRequestId) {
                                logs.logEvent("contactsStore::acceptContactRequest", ["publicKey, contactRequestId"], arguments)
                                ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.Mutual)
                            }

                            function dismissContactRequest(publicKey, contactRequestId) {
                                logs.logEvent("contactsStore::dismissContactRequest", ["publicKey, contactRequestId"], arguments)
                                ctrlContactRequestState.currentIndex = ctrlContactRequestState.indexOfValue(Constants.ContactRequestState.Dismissed)
                            }

                            function removeTrustStatus(publicKey) {
                                logs.logEvent("contactsStore::removeTrustStatus", ["publicKey"], arguments)
                                ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.unknown)
                            }

                            function verifiedUntrustworthy(publicKey) {
                                logs.logEvent("contactsStore::verifiedUntrustworthy", ["publicKey"], arguments)
                            }

                            function verifiedTrusted(publicKey) {
                                logs.logEvent("contactsStore::verifiedTrusted", ["publicKey"], arguments)
                                ctrlTrustStatus.currentIndex = ctrlTrustStatus.indexOfValue(Constants.trustStatus.trusted)
                            }

                            function cancelVerificationRequest(pubKey) {
                                logs.logEvent("contactsStore::cancelVerificationRequest", ["pubKey"], arguments)
                                ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                                ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                            }

                            function getLinkToProfile(publicKey) {
                                return Constants.userLinkPrefix + publicKey
                            }

                            function changeContactNickname(publicKey, newNickname, displayName, isEdit) {
                                logs.logEvent("contactsStore::changeContactNickname", ["publicKey", "newNickname", "displayName", "isEdit"], arguments)
                                localNickname.text = newNickname
                            }

                            function requestProfileShowcase(publicKey) {
                                logs.logEvent("contactsStore::requestProfileShowcase", ["publicKey"], arguments)
                            }
                        }
                    }
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 350

            logsView.logText: logs.logText

            ColumnLayout {
                width: parent.width
                RowLayout {
                    Layout.fillWidth: true
                    Switch {
                        id: switchOwnProfile
                        text: "Own profile"
                        checked: false
                    }
                    Switch {
                        id: ctrlReadOnly
                        text: "Readonly (preview)"
                        visible: switchOwnProfile.checked
                        checked: false
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "localNickname:" }
                    TextField {
                        id: localNickname
                        text: "Alex"
                        placeholderText: "Local Nickname"
                    }
                    Label { text: "displayName:" }
                    TextField {
                        id: displayName
                        text: "Alex Pella"
                        placeholderText: "Display Name"
                    }
                    CheckBox {
                        id: ensVerified
                        checked: true
                        text: "ensVerified"
                    }

                    Label { text: "name:" }
                    TextField {
                        id: name
                        enabled: ensVerified.checked
                        text: ensVerified.checked ? "mock-ens-name.eth" : ""
                        placeholderText: "ENS name"
                    }
                }
                RowLayout {
                    CheckBox {
                        id: userImage
                        text: "User image"
                        checked: true
                    }
                    Label {
                        font.italic: true
                        text: "or"
                    }
                    Label {
                        enabled: !userImage.checked
                        text: "colorId"
                    }
                    SpinBox {
                        id: colorId
                        enabled: !userImage.checked
                        from: 0
                        to: 11 // Theme.palette.userCustomizationColors.length
                    }
                    Label { text: "onlineStatus" }
                    ComboBox {
                        id: ctrlOnlineStatus
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.onlineStatus.unknown, text: "unknown" },
                            { value: Constants.onlineStatus.inactive, text: "inactive" },
                            { value: Constants.onlineStatus.online, text: "online" }
                        ]
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: !switchOwnProfile.checked
                    CheckBox {
                        id: ctrlIsContact
                        enabled: true
                        checked: ctrlContactRequestState.currentValue === Constants.ContactRequestState.Mutual
                        text: "isContact"
                    }
                    ComboBox {
                        id: ctrlContactRequestState
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.ContactRequestState.None, text: "None" },
                            { value: Constants.ContactRequestState.Mutual, text: "Mutual" },
                            { value: Constants.ContactRequestState.Sent, text: "Sent" },
                            { value: Constants.ContactRequestState.Received, text: "Received" },
                            { value: Constants.ContactRequestState.Dismissed, text: "Dismissed" }
                        ]
                    }
                    Label { text: "trustStatus:" }
                    ComboBox {
                        id: ctrlTrustStatus
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.trustStatus.unknown, text: "unknown" },
                            { value: Constants.trustStatus.trusted, text: "trusted" },
                            { value: Constants.trustStatus.untrustworthy, text: "untrustworthy" }
                        ]
                    }
                    CheckBox {
                        id: ctrlIsBlocked
                        text: "isBlocked"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label { text: "incomingVerificationStatus:" }
                    ComboBox {
                        id: ctrlIncomingVerificationStatus
                        enabled: ctrlIsContact.checked && !switchOwnProfile.checked
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.verificationStatus.unverified, text: "unverified" },
                            { value: Constants.verificationStatus.verifying, text: "verifying" },
                            { value: Constants.verificationStatus.verified, text: "verified" },
                            { value: Constants.verificationStatus.declined, text: "declined" },
                            { value: Constants.verificationStatus.canceled, text: "canceled" },
                            { value: Constants.verificationStatus.trusted, text: "trusted" },
                            { value: Constants.verificationStatus.untrustworthy, text: "untrustworthy" }
                        ]
                    }
                    Label { text: "verificationStatus:" }
                    ComboBox {
                        id: ctrlVerificationStatus
                        enabled: ctrlIsContact.checked && !switchOwnProfile.checked
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.verificationStatus.unverified, text: "unverified" },
                            { value: Constants.verificationStatus.verifying, text: "verifying" },
                            { value: Constants.verificationStatus.verified, text: "verified" },
                            { value: Constants.verificationStatus.declined, text: "declined" },
                            { value: Constants.verificationStatus.canceled, text: "canceled" },
                            { value: Constants.verificationStatus.trusted, text: "trusted" },
                            { value: Constants.verificationStatus.untrustworthy, text: "untrustworthy" }
                        ]
                    }
                    Button {
                        text: "Send ID request"
                        onClicked: {
                            ctrlIsContact.checked = true
                            ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                            ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                        }
                    }
                    Button {
                        text: "Reply to ID request"
                        onClicked: {
                            ctrlIsContact.checked = true
                            ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                            ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.unverified)
                        }
                    }
                    Button {
                        text: "Pending ID request"
                        onClicked: {
                            ctrlIsContact.checked = true
                            ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                            ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                        }
                    }
                    Button {
                        text: "Review ID reply"
                        onClicked: {
                            ctrlIsContact.checked = true
                            ctrlIncomingVerificationStatus.currentIndex = ctrlIncomingVerificationStatus.indexOfValue(Constants.verificationStatus.verified)
                            ctrlVerificationStatus.currentIndex = ctrlVerificationStatus.indexOfValue(Constants.verificationStatus.verifying)
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Bio:" }
                    TextField {
                        Layout.fillWidth: true
                        id: bio
                        selectByMouse: true
                        text: "Hi, I am Alex. I'm an indie developer who mainly works on web products.

I worked for several different companies and created a couple of my own products from scratch. Currently building Telescope and Prepacked.

Say hi, or find me on Twitter, GitHub, or Mastodon."
                    }
                }
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=733%3A12552
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A15078
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A17655
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A17087
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A23525
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A23932
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A23932&t=h8DUW6Eysawqe5u0-0
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=724%3A15511&t=h8DUW6Eysawqe5u0-0
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=6%3A16845&t=h8DUW6Eysawqe5u0-0
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A25437&t=h8DUW6Eysawqe5u0-0
