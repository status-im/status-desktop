import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.views.chat 1.0
import shared.status 1.0

SplitView {
    QtObject {
        id: d
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                RowLayout {
                    Button {
                        text: "Profile context menu"
                        onClicked: {
                            menu1.createObject(this).popup()
                        }
                    }
                    Button {
                        text: "Profile context menu (hide disabled items)"
                        onClicked: {
                            menu2.createObject(this).popup()
                        }
                    }
                }
            }

            Component {
                id: menu1
                ProfileContextMenu {
                    id: profileContextMenu
                    anchors.centerIn: parent
                    hideDisabledItems: false
                    profileType: profileTypeSelector.currentValue
                    trustStatus: trustStatusSelector.currentValue
                    contactType: contactTypeSelector.currentValue
                    ensVerified: ensVerifiedCheckBox.checked
                    onlineStatus: onlineStatusSelector.currentValue
                    hasLocalNickname: hasLocalNicknameCheckBox.checked
                    publicKey: publicKeyInput.text

                    onOpenProfileClicked: () => {
                        logs.logEvent("Open profile clicked for:", profileContextMenu.publicKey)
                    }
                    onCreateOneToOneChat: () => {
                        logs.logEvent("Create one-to-one chat:", profileContextMenu.publicKey)
                    }
                    onReviewContactRequest: () => {
                        logs.logEvent("Review contact request:", profileContextMenu.publicKey)
                    }
                    onSendContactRequest: () => {
                        logs.logEvent("Send contact request:", profileContextMenu.publicKey)
                    }
                    onEditNickname: () => {
                        logs.logEvent("Edit nickname:", profileContextMenu.publicKey)
                    }
                    onRemoveNickname: (displayName) => {
                        logs.logEvent("Remove nickname:", profileContextMenu.publicKey, displayName)
                    }
                    onUnblockContact: () => {
                        logs.logEvent("Unblock contact:", profileContextMenu.publicKey)
                    }
                    onMarkAsUntrusted: () => {
                        logs.logEvent("Mark as untrusted:", profileContextMenu.publicKey)
                    }
                    onRemoveTrustStatus: () => {
                        logs.logEvent("Remove trust status:", profileContextMenu.publicKey)
                    }
                    onRemoveContact: () => {
                        logs.logEvent("Remove contact:", profileContextMenu.publicKey)
                    }
                    onBlockContact: () => {
                        logs.logEvent("Block contact:", profileContextMenu.publicKey)
                    }
                    onClosed: {
                        destroy()
                    }
                }
            }

            Component {
                id: menu2
                ProfileContextMenu {
                    id: profileContextMenu
                    anchors.centerIn: parent
                    hideDisabledItems: true
                    profileType: profileTypeSelector.currentValue
                    trustStatus: trustStatusSelector.currentValue
                    contactType: contactTypeSelector.currentValue
                    ensVerified: ensVerifiedCheckBox.checked
                    onlineStatus: onlineStatusSelector.currentValue
                    hasLocalNickname: hasLocalNicknameCheckBox.checked
                    publicKey: publicKeyInput.text

                    onOpenProfileClicked: () => {
                        logs.logEvent("Open profile clicked for:", profileContextMenu.publicKey)
                    }
                    onCreateOneToOneChat: () => {
                        logs.logEvent("Create one-to-one chat:", profileContextMenu.publicKey)
                    }
                    onReviewContactRequest: () => {
                        logs.logEvent("Review contact request:", profileContextMenu.publicKey)
                    }
                    onSendContactRequest: () => {
                        logs.logEvent("Send contact request:", profileContextMenu.publicKey)
                    }
                    onEditNickname: () => {
                        logs.logEvent("Edit nickname:", profileContextMenu.publicKey)
                    }
                    onRemoveNickname: (displayName) => {
                        logs.logEvent("Remove nickname:", profileContextMenu.publicKey, displayName)
                    }
                    onUnblockContact: () => {
                        logs.logEvent("Unblock contact:", profileContextMenu.publicKey)
                    }
                    onMarkAsUntrusted: () => {
                        logs.logEvent("Mark as untrusted:", profileContextMenu.publicKey)
                    }
                    onRemoveTrustStatus: () => {
                        logs.logEvent("Remove trust status:", profileContextMenu.publicKey)
                    }
                    onRemoveContact: () => {
                        logs.logEvent("Remove contact:", profileContextMenu.publicKey)
                    }
                    onBlockContact: () => {
                        logs.logEvent("Block contact:", profileContextMenu.publicKey)
                    }

                    onClosed: {
                        destroy()
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        controls: ColumnLayout {
            spacing: 16

            TextField {
                id: publicKeyInput
                Layout.fillWidth: true
                placeholderText: "Enter public key"
            }

            Label {
                Layout.fillWidth: true
                text: "Public Key: " + (publicKeyInput.text || "0x047d6710733523714e65e783f975f2c02f5a0f43ecf6febb4e0fadb48bffae32cdc749ea366b2649c271b76e568e9bf0c173596c6e54a2659293a46947b33c9d72")
                elide: Text.ElideMiddle
            }

            ComboBox {
                id: profileTypeSelector
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Regular", value: Constants.profileType.regular },
                    { text: "Self", value: Constants.profileType.self },
                    { text: "Blocked", value: Constants.profileType.blocked },
                    { text: "Bridged", value: Constants.profileType.bridged }
                ]
                currentIndex: 0
            }

            ComboBox {
                id: trustStatusSelector
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Unknown", value: Constants.trustStatus.unknown },
                    { text: "Trusted", value: Constants.trustStatus.trusted },
                    { text: "Untrusted", value: Constants.trustStatus.untrustworthy }
                ]
                currentIndex: 0
            }

            ComboBox {
                id: contactTypeSelector
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Non Contact", value: Constants.contactType.nonContact },
                    { text: "Contact", value: Constants.contactType.contact },
                    { text: "Contact Request Received", value: Constants.contactType.contactRequestReceived },
                    { text: "Contact Request Sent", value: Constants.contactType.contactRequestSent }
                ]
                currentIndex: 0
            }

            CheckBox {
                id: ensVerifiedCheckBox
                text: "ENS Verified"
                checked: false
            }

            Label {
                Layout.fillWidth: true
                text: "ENS Verified: " + (ensVerifiedCheckBox.checked ? "Yes" : "No")
            }

            Label {
                Layout.fillWidth: true
                text: "Profile type: " + profileTypeSelector.currentText
            }

            Label {
                Layout.fillWidth: true
                text: "Trust status: " + trustStatusSelector.currentText
            }

            Label {
                Layout.fillWidth: true
                text: "Contact type: " + contactTypeSelector.currentText
            }

            ComboBox {
                id: onlineStatusSelector
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Unknown", value: Constants.onlineStatus.unknown },
                    { text: "Inactive", value: Constants.onlineStatus.inactive },
                    { text: "Online", value: Constants.onlineStatus.online }
                ]
                currentIndex: 2  // Default to online
            }

            Label {
                Layout.fillWidth: true
                text: "Online status: " + onlineStatusSelector.currentText
            }

            CheckBox {
                id: hasLocalNicknameCheckBox
                text: "Has Local Nickname"
                checked: false
            }

            Label {
                Layout.fillWidth: true
                text: "Has Local Nickname: " + (hasLocalNicknameCheckBox.checked ? "Yes" : "No")
            }
        }
    }
}

// category: Views