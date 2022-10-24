import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        MyProfileView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            isKeycardUser: false

            communitiesModel: ListModel {
                ListElement {
                    name: "Status CCs"
                    amISectionAdmin: true
                    image: "data:image/jpeg;base64,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"
                    color: "#88B0FF"
                }
                ListElement {
                    name: "FRENZ"
                    amISectionAdmin: false
                    image: "data:image/jpeg;base64,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"
                    color: "#51d0f0"
                }
            }

            accountsModel: ListModel {
                ListElement {
                    name: "Status account"
                    address: "0x236a0c00ba6edc6af8945e85eacca9100183919c"
                    color: "#4360df"
                    emoji: '<img class="emoji" draggable="false" alt="👲🏼" src="qrc:/StatusQ/src/assets/twemoji/svg/1f472-1f3fc.svg?72x72" width="16" height="16" style="vertical-align: top"/>'
                }
            }

            accountSettings: QtObject {
                readonly property bool currentStoredValue: false
                property bool storeToKeychainValue: false

            }
            accountSensitiveSettings: QtObject {
                readonly property bool communitiesEnabled: true
                readonly property bool isWalletEnabled: true
            }

            contactsStore: ContactsStore {
                myPublicKey: "0x123"

                function hasReceivedVerificationRequestFrom(publicKey) {
                    logs.logEvent("contactsStore::hasReceivedVerificationRequestFrom", ["publicKey"], arguments)
                }
                function joinPrivateChat(publicKey) {
                    logs.logEvent("contactsStore::joinPrivateChat", ["publicKey"], arguments)
                }
                function acceptContactRequest(publicKey) {
                    logs.logEvent("contactsStore::acceptContactRequest", ["publicKey"], arguments)
                }
                function dismissContactRequest(publicKey) {
                    logs.logEvent("contactsStore::dismissContactRequest", ["publicKey"], arguments)
                }
                function removeContact(publicKey) {
                    logs.logEvent("contactsStore::removeContact", ["publicKey"], arguments)
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
                function markUntrustworthy(publicKey) {
                    logs.logEvent("contactsStore::markUntrustworthy", ["publicKey"], arguments)
                }
            }

            privacyStore: PrivacyStore {
                mnemonicBackedUp: false

                function changePassword(password, newPassword) {
                    logs.logEvent("privacyStore::changePassword", ["password", "newPassword"], arguments)
                }

                function getMnemonic() {
                    logs.logEvent("privacyStore::getMnemonic")
                    return "abandon gossip feed snow key resist name citizen tobacco seat invite excuse"
                }

                function removeMnemonic() {
                    logs.logEvent("privacyStore::removeMnemonic")
                }

                function getMnemonicWordAtIndex(index) {
                    logs.logEvent("privacyStore::getMnemonicWordAtIndex", ["index"], arguments)
                    return "hello"
                }

                function validatePassword(password) {
                    logs.logEvent("privacyStore::validatePassword", ["password"], arguments)
                    return true
                }

                function storeToKeyChain(pass) {
                    logs.logEvent("privacyStore::storeToKeyChain", ["pass"], arguments)
                }
            }

            profileStore: ProfileStore {
                profileModule: QtObject {
                    property string bio: 'General John D. "Johnny" Rico is a general in the Mobile Infantry of the United Citizen Federation. During his life, John Rico has become one of the most representative icons of the United Citizen Federation. Johnny inspired courage and valor in every battle as a freedom fighter, gallant soldier, and brave man. He is an exemplary character for all men and women of the Federation.'
                    property string socialLinksJson: "profileModule.socialLinksJson"
                    property var socialLinksModel: QtObject {}
                    property var temporarySocialLinksModel: ListModel {}
                    property bool socialLinksDirty: false
                    property var privacyStore: QtObject {}
                }

                property var temporarySocialLinksModel: ListModel {
                        ListElement {
                            uuid: "b7169e57-e1c0-401e-a9c6-95ef257b23f2"
                            text: "__twitter"
                            url: ""
                            linkType: 1
                        }
                        ListElement {
                            uuid: "076b6a2a-e57e-4b7b-87bc-de7d8ce08e7f"
                            text: "__personal_site"
                            url: ""
                            linkType: 2
                        }
                        ListElement {
                            uuid: "dd64bc80-f49c-497d-a5f6-deb1b920d5d5"
                            text: "__github"
                            url: ""
                            linkType: 3
                        }
                        ListElement {
                            uuid: "3bd5c7c4-4e4a-4e4a-9526-475645b82af3"
                            text: "__youtube"
                            url: ""
                            linkType: 4
                        }
                        ListElement {
                            uuid: "7fd3b351-152e-48ad-93a9-9e7555fb9f2b"
                            text: "__discord"
                            url: ""
                            linkType: 5
                        }
                        ListElement {
                            uuid: "edbb77da-27a1-436b-b618-f37a78e9d773"
                            text: "__telegram"
                            url: ""
                            linkType: 6
                        }
                }

                pubkey: "userProfile.pubKey"
                name: "userProfile.name" // in case of ens returns pretty ens form
                username: "userProfile.username"
                displayName: "John Rico"
                ensName: "userProfile.preferredName || userProfile.firstEnsName || userProfile.ensName"
                profileLargeImage: "data:image/jpeg;base64,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"
                icon: "userProfile.icon"
                userDeclinedBackupBanner: true

                onUserDeclinedBackupBannerChanged: {
                    logs.logEvent("profileStore::signals::onUserDeclinedBackupBannerChanged")
                }

                // TODO: replace later with contact details
                // details: Utils.getContactDetailsAsJson(pubkey)
                details: "{}"

                function uploadImage(source, aX, aY, bX, bY) {
                    logs.logEvent("profileStore::uploadImage", ["source", "aX", "aY", "bX", "bY"], arguments)
                }

                function removeImage() {
                    logs.logEvent("profileStore::removeImage")
                }

                function getQrCodeSource(publicKey) {
                    logs.logEvent("profileStore::getQrCodeSource", ["publicKey"], arguments)
                }

                function copyToClipboard(value) {
                    logs.logEvent("profileStore::copyToClipboard", ["value"], arguments)
                }

                function setDisplayName(displayName) {
                    logs.logEvent("profileStore::setDisplayName", ["displayName"], arguments)
                }

                function createCustomLink(text, url) {
                    logs.logEvent("profileStore::createCustomLink", ["text", "url"], arguments)
                }

                function removeCustomLink(uuid) {
                    logs.logEvent("profileStore::removeCustomLink", ["uuid"], arguments)
                }

                function updateLink(uuid, text, url) {
                    logs.logEvent("profileStore::updateLink", ["uuid", "text", "url"], arguments)
                }

                function resetSocialLinks() {
                    logs.logEvent("profileStore::resetSocialLinks")
                }

                function saveSocialLinks() {
                    logs.logEvent("profileStore::saveSocialLinks")
                }

                function setBio(bio) {
                    logs.logEvent("profileStore::setBio", ["bio"], arguments)
                }

            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
    }
}
