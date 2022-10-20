import QtQuick 2.14
import QtQuick.Controls 2.14

import Storybook 1.0

import utils 1.0
import shared.views 1.0

SplitView {
    id: root

    // globalUtilsInst and mainModuleInst injection/replacement
    QtObject {
        Component.onCompleted: {
            Utils.globalUtilsInst = {
                getEmojiHashAsJson: function(publicKey) {
                    return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
                },
                getColorId: function(publicKey) { return 0 }, // TODO
                getCompressedPk: function(publicKey) { return publicKey }
            }
            Utils.mainModuleInst = {
                getContactDetailsAsJson: function(publicKey, getVerificationRequest) // TODO make an editor for this
                {
                    return JSON.stringify({ displayName: "Mock User Name",
                                              optionalName: "OriginalMockUser",
                                              displayIcon: "", // TODO
                                              publicKey: publicKey,
                                              name: "mock-ens-name",
                                              ensVerified: true,
                                              alias: "Mock User Triplet",
                                              lastUpdated: Date.now(),
                                              lastUpdatedLocally: Date.now(),
                                              localNickname: "MockNickname",
                                              thumbnailImage: "", // TODO
                                              largeImage: "", // TODO
                                              isContact: true,
                                              isAdded: true,
                                              isBlocked: false,
                                              removed: false,
                                              requestReceived: true,
                                              hasAddedUs: true, // same as above
                                              isSyncing: false,
                                              removed: false,
                                              trustStatus: Constants.trustStatus.unknown,
                                              verificationStatus: Constants.verificationStatus.unverified,
                                              incomingVerificationStatus: Constants.verificationStatus.unverified,
                                              socialLinks: "", // TODO
                                              bio: "Hello from MockMainModule, I am a mock user and this is my bio."
                                          })
                }
            }
        }

        Component.onDestruction: {
            Qt.callLater(function () {
                Utils.globalUtilsInst = {}
                Utils.mainModuleInst = {}
            })
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

                ProfileDialogView {
                    implicitWidth: 640

                    publicKey: switchOwnProfile.checked ? "0xdeadbeef" : "0xrandomguy"

                    Component.onCompleted: {
                        Global.appMain = root // FIXME this is here for the popups to work
                    }

                    profileStore: QtObject {
                        readonly property string pubkey: "0xdeadbeef"
                        property string ensName: "mock-ens-name" // TODO match "myPublicKey" from contactsStore/MockMainModule

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

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            Row {
                Switch {
                    id: switchOwnProfile
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Own profile"
                    checked: false
                }
            }
        }
    }
}
