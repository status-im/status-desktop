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
                                      verificationStatus: Constants.verificationStatus.unverified,
                                      incomingVerificationStatus: Constants.verificationStatus.unverified,
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

    Logs { id: logs }

    Popups {
        popupParent: root
        rootStore: QtObject {
            property var contactStore: QtObject {
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

                function sendVerificationRequest(publicKey, challenge) {
                    logs.logEvent("rootStore::contactStore::sendVerificationRequest", ["publicKey", "challenge"], arguments)
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

                        profileStore: QtObject {
                            readonly property string pubkey: "0xdeadbeef"
                            readonly property string ensName: name.text

                            function getQrCodeSource() {
                                return "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"
                            }
                            function copyToClipboard(text) {
                                logs.logEvent("profileStore::copyToClipboard", ["text"], arguments)
                            }
                            function requestProfileShowcase(publicKey) {
                                logs.logEvent("profileStore::requestProfileShowcase", ["publicKey"], arguments)
                            }

                            readonly property var profileShowcaseCommunitiesModel: CommunitiesModel {}
                            readonly property var profileShowcaseAccountsModel: WalletAccountsModel {}
                            readonly property var profileShowcaseCollectiblesModel: ManageCollectiblesModel {}
                            readonly property var profileShowcaseAssetsModel: assetsStore.groupedAccountAssetsModel
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
                            }

                            function acceptContactRequest(publicKey, contactRequestId) {
                                logs.logEvent("contactsStore::acceptContactRequest", ["publicKey, contactRequestId"], arguments)
                            }

                            function dismissContactRequest(publicKey, contactRequestId) {
                                logs.logEvent("contactsStore::dismissContactRequest", ["publicKey, contactRequestId"], arguments)
                            }

                            function removeTrustStatus(publicKey) {
                                logs.logEvent("contactsStore::removeTrustStatus", ["publicKey"], arguments)
                            }

                            function verifiedUntrustworthy(publicKey) {
                                logs.logEvent("contactsStore::verifiedUntrustworthy", ["publicKey"], arguments)
                            }

                            function verifiedTrusted(publicKey) {
                                logs.logEvent("contactsStore::verifiedTrusted", ["publicKey"], arguments)
                            }

                            function getLinkToProfile(publicKey) {
                                return Constants.userLinkPrefix + publicKey
                            }

                            function changeContactNickname(publicKey, newNickname, displayName, isEdit) {
                                logs.logEvent("contactsStore::changeContactNickname", ["publicKey", "newNickname", "displayName", "isEdit"], arguments)
                                localNickname.text = newNickname
                            }
                        }

                        walletStore: QtObject {
                            function setFilterAddress(address) {
                                logs.logEvent("walletStore::setFilterAddress", ["address"], arguments)
                            }

                            function getSavedAddress(address) {
                                return {
                                    name: "My Status Saved Account",
                                    address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000",
                                    ens: false,
                                    colorId: Constants.walletAccountColors.primary,
                                    chainShortNames: "",
                                    isTest: false
                                }
                            }

                            function createOrUpdateSavedAddress(name, address, ens, colorId, chainShortNames) {
                                logs.logEvent("walletStore::createOrUpdateSavedAddress", ["name", "address", "ens", "colorId", "chainShortNames"],
                                              arguments)
                            }
                        }

                        networkConnectionStore: QtObject {
                            readonly property bool sendBuyBridgeEnabled: true
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
                        text: "Nick"
                        placeholderText: "Local Nickname"
                    }
                    Label { text: "displayName:" }
                    TextField {
                        id: displayName
                        text: "Alex Pella"
                        placeholderText: "Display Name"
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
                }
                RowLayout {
                    Layout.fillWidth: true
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
                    CheckBox {
                        id: ctrlIsBlocked
                        text: "isBlocked"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: !switchOwnProfile.checked
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
