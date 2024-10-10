import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import shared.popups 1.0
import Models 1.0

import utils 1.0
import shared.views.chat 1.0
import shared.status 1.0

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            Item {
                Layout.preferredHeight: 50
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "Open Add Nickname Popup"
                    onClicked: {
                        nicknamePopup.nickname = ""
                        nicknamePopup.open()
                    }
                }

                Button {
                    text: "Open Edit Nickname Popup"
                    onClicked: {
                        nicknamePopup.nickname = nicknameInput.text
                        nicknamePopup.open()
                    }
                }
            }

            Item {
                Layout.preferredWidth: nicknamePopup.implicitWidth
                Layout.preferredHeight: nicknamePopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                NicknamePopup {
                    id: nicknamePopup
                    visible: false
                    nickname: nicknameInput.text
                    publicKey: publicKeyInput.text
                    localNickname: localNicknameInput.text
                    name: nameInput.text
                    displayName: displayNameInput.text
                    alias: aliasInput.text
                    ensVerified: ensVerifiedCheckBox.checked
                    onlineStatus: onlineStatusSelector.currentValue
                    largeImage: largeImageInput.text
                    isContact: isContactCheckBox.checked
                    trustStatus: trustStatusSelector.currentValue
                    isBlocked: isBlockedCheckBox.checked
                    onEditDone: function(newNickname) {
                        nicknamePopup.close()
                        log("Nickname edited: " + newNickname)
                    }
                    onRemoveNicknameRequested: {
                        nicknamePopup.close()
                        log("Nickname removed")
                    }
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400
        SplitView.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            Label {
                text: "Nickname Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Nickname" }
            TextField {
                id: nicknameInput
                Layout.fillWidth: true
                placeholderText: "Enter nickname"
                text: nicknamePopup.nickname
                onTextChanged: {
                    nicknamePopup.nickname = text
                }
            }

            Label { text: "Public Key" }
            TextField {
                id: publicKeyInput
                Layout.fillWidth: true
                placeholderText: "Enter public key"
            }

            Label { text: "Local Nickname" }
            TextField {
                id: localNicknameInput
                Layout.fillWidth: true
                placeholderText: "Local Nickname"
            }

            Label { text: "Name" }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: "Name"
            }

            Label { text: "Display Name" }
            TextField {
                id: displayNameInput
                Layout.fillWidth: true
                placeholderText: "Display Name"
            }

            Label { text: "Alias" }
            TextField {
                id: aliasInput
                Layout.fillWidth: true
                placeholderText: "Alias"
            }

            CheckBox {
                id: ensVerifiedCheckBox
                text: "ENS Verified"
            }

            Label { text: "Online Status" }
            ComboBox {
                id: onlineStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Offline", value: Constants.onlineStatus.inactive },
                    { text: "Online", value: Constants.onlineStatus.online },
                    { text: "Away", value: Constants.onlineStatus.away },
                    { text: "Busy", value: Constants.onlineStatus.busy }
                ]
            }

            Label { text: "Large Image URL" }
            TextField {
                id: largeImageInput
                Layout.fillWidth: true
                placeholderText: "Large Image URL"
            }

            CheckBox {
                id: isContactCheckBox
                text: "Is Contact"
            }

            Label { text: "Trust Status" }
            ComboBox {
                id: trustStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Untrusted", value: Constants.trustStatus.unknown },
                    { text: "Trusted", value: Constants.trustStatus.trusted },
                    { text: "Verified", value: Constants.trustStatus.verifiedTrusted }
                ]
            }

            CheckBox {
                id: isBlockedCheckBox
                text: "Is Blocked"
            }

            Item {
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "Logs"
                    font.bold: true
                    font.pixelSize: 16
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    clip: true

                    TextArea {
                        id: logsTextArea
                        readOnly: true
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                    }
                }

                Button {
                    text: "Clear Logs"
                    onClicked: logsTextArea.clear()
                }
            }
        }
    }

    function log(message) {
        var timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
        logsTextArea.append(timestamp + ": " + message)
    }
}
