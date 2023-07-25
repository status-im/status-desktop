import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.views 1.0
import mainui 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

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

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

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
        function getContactDetailsAsJson(publicKey, getVerificationRequest) {
            return JSON.stringify({ displayName: displayName.text || "Mock User Name",
                                      optionalName: optionalName.text,
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
                                      isContact: isContact.checked,
                                      isAdded: isAdded.checked,
                                      isBlocked: isBlocked.checked,
                                      removed: removed.checked,
                                      requestReceived: hasAddedUs.checked,
                                      hasAddedUs: hasAddedUs.checked, // same as above
                                      isSyncing: false,
                                      trustStatus: trustStatus.currentValue,
                                      verificationStatus: Constants.verificationStatus.unverified,
                                      incomingVerificationStatus: Constants.verificationStatus.unverified,
                                      contactRequestState: Constants.ContactRequestState.None,
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
                                                     }])
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
                function changeContactNickname(publicKey, newNickname) {
                    logs.logEvent("rootStore::contactStore::changeContactNickname", ["publicKey", "newNickname"], arguments)
                }
            }
        }
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

                        publicKey: switchOwnProfile.checked ? "0xdeadbeef" : "0xrandomguy"

                        onCloseRequested: logs.logEvent("closeRequested()")

                        profileStore: QtObject {
                            readonly property string pubkey: "0xdeadbeef"
                            readonly property string ensName: name.text

                            function getQrCodeSource() {
                                return ""
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

                            function getLinkToProfile(publicKey) {
                                return "https://status.app/u/" + publicKey
                            }
                        }

                        communitiesModel: ListModel {
                            ListElement {
                                name: "Not the cool gang"
                                memberRole: 0 // Constants.memberRole.none
                                isControlNode: false
                                description: "Nothing to write home about"
                                color: "indigo"
                                image: ""
                                joined: true
                                members: [
                                    ListElement { displayName: "Joe" }
                                ]
                            }
                            ListElement {
                                name: "Awesome bunch"
                                memberRole: 4 // Constants.memberRole.admin
                                isControlNode: false
                                description: "Where the cool guys hang out & Nothing to write home about"
                                color: "green"
                                image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                                        nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                                joined: true
                                members: [
                                    ListElement { displayName: "Alex" },
                                    ListElement { displayName: "AlexJb" },
                                    ListElement { displayName: "Michal" },
                                    ListElement { displayName: "Noelia" },
                                    ListElement { displayName: "Lukáš" }
                                ]
                            }
                            ListElement {
                                name: "Invisible community (should not display!)"
                                memberRole: 1 // Constants.memberRole.owner
                                isControlNode: true
                                description: "Get outta here"
                                color: "red"
                                image: ""
                                joined: false
                                members: []
                            }
                        }

                        walletStore: QtObject {
                            function setFilterAddress(address) {
                                logs.logEvent("walletStore::setFilterAddress", ["address"], arguments)
                            }

                            function selectCollectible(slug, id) {
                                logs.logEvent("walletStore::selectCollectible", ["slug", "id"], arguments)
                            }

                            readonly property var accounts: ListModel {
                                ListElement {
                                    name: "My Status Account"
                                    address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
                                    colorId: "primary"
                                    emoji: "🇨🇿"
                                    walletType: ""
                                }
                                ListElement {
                                    name: "testing (no emoji, colored, saved, seed)"
                                    address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
                                    colorId: "turquoise"
                                    walletType: "seed"
                                }
                                ListElement {
                                    name: "My Bro's Account"
                                    address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
                                    colorId: "sky"
                                    emoji: "🇸🇰"
                                    walletType: "watch"
                                }
                                ListElement {
                                    name: "Keycard"
                                    address: "0xdeadbeef"
                                    colorId: "purple"
                                    emoji: ""
                                    walletType: "key"
                                }
                            }

                            function getNameForSavedWalletAddress(address) {
                                return CoreUtils.ModelUtils.getByKey(savedAddresses, "address", address, "name") ?? ""
                            }

                            function createOrUpdateSavedAddress(name, address, favourite) {
                                logs.logEvent("walletStore::createOrUpdateSavedAddress", ["name", "address", "favourite"], arguments)
                                savedAddresses.append({name, address, favourite, ens: false})
                                return "" // no error
                            }

                            readonly property var savedAddresses: ListModel {
                                ListElement {
                                    name: "My Status Saved Account"
                                    address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
                                    favourite: true
                                    ens: false
                                }
                            }

                            readonly property var assets: ListModel {
                                readonly property var data: [
                                    {
                                        symbol: "MANA",
                                        enabledNetworkBalance: {
                                            amount: 301,
                                            symbol: "MANA"
                                        },
                                        changePct24hour: -2.1,
                                        visibleForNetworkWithPositiveBalance: true
                                    },
                                    {
                                        symbol: "AAVE",
                                        enabledNetworkBalance: {
                                            amount: 23.3,
                                            symbol: "AAVE"
                                        },
                                        changePct24hour: 4.56,
                                        visibleForNetworkWithPositiveBalance: true
                                    },
                                    {
                                        symbol: "POLY",
                                        enabledNetworkBalance: {
                                            amount: 3590,
                                            symbol: "POLY"
                                        },
                                        changePct24hour: -11.6789,
                                        visibleForNetworkWithPositiveBalance: true
                                    },
                                    {
                                        symbol: "CDT",
                                        enabledNetworkBalance: {
                                            amount: 1000,
                                            symbol: "CDT"
                                        },
                                        changePct24hour: 0,
                                        visibleForNetworkWithPositiveBalance: true
                                    },
                                    {
                                        symbol: "MKR",
                                        enabledNetworkBalance: {
                                            amount: 1.3,
                                            symbol: "MKR"
                                        },
                                        //changePct24hour: undefined // NB 'undefined' on purpose
                                        visibleForNetworkWithPositiveBalance: true
                                    },
                                    {
                                        symbol: "InvisibleHere",
                                        enabledNetworkBalance: {},
                                        changePct24hour: 0,
                                        visibleForNetworkWithPositiveBalance: false
                                    }
                                ]
                                Component.onCompleted: append(data)
                            }

                            readonly property var flatCollectibles: ListModel {
                                readonly property var data: [
                                    {
                                        //id: 123,
                                        name: "Crypto Kitties",
                                        description: "Super Crypto Kitty",
                                        backgroundColor: "",
                                        imageUrl: ModelsData.collectibles.cryptoKitties,
                                        permalink: "",
                                        isLoading: false
                                    },
                                    {
                                        id: 34545656768,
                                        name: "Kitty 1",
                                        description: "",
                                        backgroundColor: "green",
                                        imageUrl: ModelsData.collectibles.kitty1Big,
                                        permalink: "",
                                        isLoading: false
                                    },
                                    {
                                        id: 123456,
                                        name: "Kitty 2",
                                        description: "",
                                        backgroundColor: "",
                                        imageUrl: ModelsData.collectibles.kitty2Big,
                                        permalink: "",
                                        isLoading: false
                                    },
                                    {
                                        id: 12345645459537432,
                                        name: "",
                                        description: "Kitty 3 description",
                                        backgroundColor: "oink",
                                        imageUrl: ModelsData.collectibles.kitty3Big,
                                        permalink: "",
                                        isLoading: false
                                    },
                                    {
                                        id: 691,
                                        name: "KILLABEAR #691",
                                        description: "Please note that weapons are not yet reflected in the rarity stats.",
                                        backgroundColor: "#807c56",
                                        imageUrl: "https://assets.killabears.com/content/killabears/img/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.png",
                                        permalink: "https://opensea.io/assets/ethereum/0xc99c679c50033bbc5321eb88752e89a93e9e83c5/691",
                                        isLoading: true
                                    }
                                ]
                                Component.onCompleted: append(data)
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
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "localNickname:" }
                    TextField {
                        id: localNickname
                        text: "MockNickname"
                        placeholderText: "Local Nickname"
                    }
                    Label { text: "displayName:" }
                    TextField {
                        id: displayName
                        placeholderText: "Display Name"
                    }
                    Label { text: "optionalName:" }
                    TextField {
                        id: optionalName
                        placeholderText: "Optional/Original Name"
                        text: ""
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
                        id: isContact
                        enabled: false
                        checked: isAdded.checked && hasAddedUs.checked
                        text: "isContact"
                    }
                    CheckBox {
                        id: isAdded
                        checked: true
                        text: "isAdded"
                    }
                    CheckBox {
                        id: hasAddedUs
                        checked: true
                        text: "hasAddedUs"
                    }
                    CheckBox {
                        id: removed
                        text: "removed"
                    }
                    CheckBox {
                        id: isBlocked
                        text: "isBlocked"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: !switchOwnProfile.checked
                    Label { text: "trustStatus:" }
                    ComboBox {
                        id: trustStatus
                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { value: Constants.trustStatus.unknown, text: "unknown" },
                            { value: Constants.trustStatus.trusted, text: "trusted" },
                            { value: Constants.trustStatus.untrustworthy, text: "untrustworthy" }
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
