import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.1

import shared.views.chat 1.0
import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            ProfileContextMenu {
                anchors.centerIn: parent
                visible: true
                closePolicy: Popup.NoAutoClose
                userIcon: useIconCheckBox.checked ? ModelsData.icons.cryptPunks : ""

                compressedPubKey: "zQ3shQBu4PRDX17veeYYhSczbTjgi44iTXxcMNvQLeyQsBDF4"
                displayName: displayNameTextField.text
                hideDisabledItems: hideDisabledCheckBox.checked
                profileType: profileTypeSelector.currentValue
                trustStatus: trustStatusSelector.currentValue
                contactType: contactTypeSelector.currentValue
                ensVerified: ensVerifiedCheckBox.checked
                onlineStatus: onlineStatusSelector.currentValue
                hasLocalNickname: hasLocalNicknameCheckBox.checked
                chatType: chatTypeSelector.currentValue
                isAdmin: isAdminCheckBox.checked

                colorHash: [
                    { segmentLength: 3, colorId: 11 },
                    { segmentLength: 5, colorId: 9  },
                    { segmentLength: 1, colorId: 26 },
                    { segmentLength: 2, colorId: 19 },
                    { segmentLength: 5, colorId: 17 }
                ]

                colorId: colorIdSpinBox.value

                onOpenProfileClicked: logs.logEvent("Open profile clicked")
                onCreateOneToOneChat: logs.logEvent("Create one-to-one chat clicked")
                onReviewContactRequest: logs.logEvent("Review contact request")
                onSendContactRequest: logs.logEvent("Send contact request")
                onEditNickname: logs.logEvent("Edit nickname")
                onRemoveNickname: logs.logEvent("Remove nickname")
                onUnblockContact: logs.logEvent("Unblock contact")
                onMarkAsUntrusted: logs.logEvent("Mark as untrusted")
                onRemoveTrustStatus: logs.logEvent("Remove trust status")
                onRemoveContact: logs.logEvent("Remove contact")
                onBlockContact: logs.logEvent("Block contact")
                onRemoveFromGroup: logs.logEvent("Remove from group")

                onClosed: open()
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 250
        SplitView.preferredWidth: 280

        logsView.logText: logs.logText

        controls: ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                id: columnLayout

                spacing: 8

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Display name:"
                    }

                    TextField {
                        id: displayNameTextField

                        Layout.fillWidth: true

                        placeholderText: "Display name"
                        text: "Display name"
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Color id:"
                    }

                    SpinBox {
                        id: colorIdSpinBox

                        from: 0
                        to: 10
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Profile type:"
                    }

                    ComboBox {
                        id: profileTypeSelector

                        Layout.fillWidth: true

                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { text: "Regular", value: Constants.profileType.regular },
                            { text: "Self", value: Constants.profileType.self },
                            { text: "Blocked", value: Constants.profileType.blocked },
                            { text: "Bridged", value: Constants.profileType.bridged }
                        ]
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Trust status:"
                    }

                    ComboBox {
                        id: trustStatusSelector

                        Layout.fillWidth: true

                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { text: "Unknown", value: Constants.trustStatus.unknown },
                            { text: "Trusted", value: Constants.trustStatus.trusted },
                            { text: "Untrusted", value: Constants.trustStatus.untrustworthy }
                        ]
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Contact type:"
                    }

                    ComboBox {
                        id: contactTypeSelector

                        Layout.fillWidth: true

                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { text: "Non Contact", value: Constants.contactType.nonContact },
                            { text: "Contact", value: Constants.contactType.contact },
                            { text: "Contact Request Received", value: Constants.contactType.contactRequestReceived },
                            { text: "Contact Request Sent", value: Constants.contactType.contactRequestSent }
                        ]
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Online status:"
                    }

                    ComboBox {
                        id: onlineStatusSelector

                        Layout.fillWidth: true

                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { text: "Online", value: Constants.onlineStatus.online },
                            { text: "Unknown", value: Constants.onlineStatus.unknown },
                            { text: "Inactive", value: Constants.onlineStatus.inactive }
                        ]
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Chat type:"
                    }

                    ComboBox {
                        id: chatTypeSelector

                        Layout.fillWidth: true

                        textRole: "text"
                        valueRole: "value"
                        model: [
                            { text: "Unknown", value: Constants.chatType.unknown },
                            { text: "Category", value: Constants.chatType.category },
                            { text: "One-to-One", value: Constants.chatType.oneToOne },
                            { text: "Public Chat", value: Constants.chatType.publicChat },
                            { text: "Private Group Chat", value: Constants.chatType.privateGroupChat },
                            { text: "Profile", value: Constants.chatType.profile },
                            { text: "Community Chat", value: Constants.chatType.communityChat }
                        ]
                    }
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    CheckBox {
                        id: useIconCheckBox
                        text: "Use icon"
                        checked: true
                    }

                    CheckBox {
                        id: ensVerifiedCheckBox
                        text: "ENS Verified"
                        checked: false
                    }

                    CheckBox {
                        id: hasLocalNicknameCheckBox

                        text: "Has Local Nickname"
                        checked: false
                    }

                    CheckBox {
                        id: isAdminCheckBox
                        text: "Is Admin"
                        checked: false
                    }
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                CheckBox {
                    id: hideDisabledCheckBox

                    text: "Hide disabled entries (debug)"
                    checked: true
                }
            }
        }
    }

    Settings {
        property alias profileTypeIndex: profileTypeSelector.currentIndex
        property alias trustStatusIndex: trustStatusSelector.currentIndex
        property alias contactTypeIndex: contactTypeSelector.currentIndex
        property alias onlineStatusIndex: onlineStatusSelector.currentIndex
        property alias chatTypeIndex: chatTypeSelector.currentIndex

        property alias useIcon: useIconCheckBox.checked
        property alias ensVerified: ensVerifiedCheckBox.checked
        property alias hasLocalNickname: hasLocalNicknameCheckBox.checked
        property alias isAdmin: isAdminCheckBox.checked
        property alias hideDisabled: hideDisabledCheckBox.checked
    }
}

// category: Views
// status: good
// https://www.figma.com/design/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=7898-265693&node-type=canvas&m=dev
