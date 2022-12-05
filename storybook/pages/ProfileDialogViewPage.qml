import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

import utils 1.0
import shared.views 1.0

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
                                      localNickname: "MockNickname",
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

                        Component.onCompleted: {
                            Global.appMain = root // FIXME this is here for the popups to work
                        }

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

                            function hasReceivedVerificationRequestFrom(publicKey) {
                                return false
                            }

                            function joinPrivateChat(publicKey) {
                                logs.logEvent("contactsStore::joinPrivateChat", ["publicKey"], arguments)
                            }

                            function markUntrustworthy(publicKey) {
                                logs.logEvent("contactsStore::markUntrustworthy", ["publicKey"], arguments)
                            }

                            function removeContact(publicKey) {
                                logs.logEvent("contactsStore::removeContact", ["publicKey"], arguments)
                            }

                            function acceptContactRequest(publicKey) {
                                logs.logEvent("contactsStore::acceptContactRequest", ["publicKey"], arguments)
                            }

                            function dismissContactRequest(publicKey) {
                                logs.logEvent("contactsStore::dismissContactRequest", ["publicKey"], arguments)
                            }

                            function removeTrustStatus(publicKey) {
                                logs.logEvent("contactsStore::removeTrustStatus", ["publicKey"], arguments)
                            }

                            function removeContactRequestRejection(publicKey) {
                                logs.logEvent("contactsStore::removeContactRequestRejection", ["publicKey"], arguments)
                            }

                            function verifiedUntrustworthy(publicKey) {
                                logs.logEvent("contactsStore::verifiedUntrustworthy", ["publicKey"], arguments)
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
                        text: ensVerified.checked ? "mock-ens-name" : ""
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
                        text: "Hello from MockMainModule, I am a mock user and this is my bio."
                    }
                }
            }
        }
    }
}
