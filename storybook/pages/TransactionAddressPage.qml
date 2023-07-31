import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import shared.controls 1.0

import utils 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: loader
            anchors.margins: -1
            color: "transparent"
            border.width: 1
            border.color: "#20000000"
        }

        // globalUtilsInst mock
        QtObject {
            function getCompressedPk(publicKey) { return "zx3sh" + publicKey }
            function getColorHashAsJson(publicKey) {
                return JSON.stringify([{"segmentLength":1,"colorId":12},{"segmentLength":5,"colorId":18},
                                       {"segmentLength":3,"colorId":25},{"segmentLength":3,"colorId":23},
                                       {"segmentLength":1,"colorId":10},{"segmentLength":3,"colorId":26},
                                       {"segmentLength":2,"colorId":30},{"segmentLength":1,"colorId":18},
                                       {"segmentLength":4,"colorId":28},{"segmentLength":1,"colorId":17},
                                       {"segmentLength":2,"colorId":2}])
            }
            function isCompressedPubKey(publicKey) { return true }
            function getColorId(publicKey) { return Math.floor(Math.random() * 10) }

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
            function getContactDetailsAsJson(publicKey, getVerification) {
                return JSON.stringify({
                    displayName: "ArianaP",
                    displayIcon: "",
                    publicKey: publicKey,
                    name: "",
                    alias: "",
                    localNickname: "",
                    isContact: d.isContact
                })
            }
            function isEnsVerified(publicKey) { return false }

            Component.onCompleted: {
                Utils.mainModuleInst = this
                root.mainModuleReady = true
            }
            Component.onDestruction: {
                root.mainModuleReady = false
                Utils.mainModuleInst = {}
            }
        }

        QtObject {
            id: d
            property string addressPrefixString: "eth:opt:arb:"
            property string addressName: "Ariana Pearlona"
            property bool isContact: true
            property bool isWallet: false
            property bool isSavedAccount: false
            property bool showPrefix: true
            readonly property string displayAddress: (d.showPrefix ? d.addressPrefixString : "") + "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B"
        }

        QtObject {
            id: contactsStoreMockup
            readonly property var myContactsModel: QtObject {
                signal itemChanged(address: string)
            }

            function getContactPublicKeyByAddress(address) {
                return d.isContact ? "zQ3shWU7xpM5YoG19KP5JDRiSs1AdWtjpnrWEerMkxfQnYo7x" : ""
            }
        }

        QtObject {
            id: rootStoreMockup

            readonly property var accounts: QtObject {
                signal itemChanged(address: string)
            }

            readonly property var savedAddresses: QtObject {
                readonly property var sourceModel: QtObject {
                    signal itemChanged(address: string)
                }
            }

            function getNameForSavedWalletAddress(address) {
                return d.isSavedAccount ? d.addressName : ""
            }
            function getEmojiForWalletAddress(address) {
                return '<img class="emoji" draggable="false" alt="??" src="' + Style.emoji("1f61b") + '?72x72" width="16" height="16" style="vertical-align: top"/>'
            }
            function getColorForWalletAddress(address) {
                return "blue"
            }
            function getNameForWalletAddress(address) {
                return d.isWallet ? d.addressName : ""
            }
        }

        Loader {
            id: loader
            anchors.centerIn: parent
            width: 400
            active: root.globalUtilsReady && root.mainModuleReady
            sourceComponent: TransactionAddress {
                width: parent.width
                address: d.displayAddress
                rootStore: rootStoreMockup
                contactsStore: contactsStoreMockup
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        SplitView.fillWidth: true

        ColumnLayout {
            spacing: 5
            Label {
                text: "Account type"
            }
            RadioButton {
                text: "contact"
                checked: d.isContact
                onClicked: {
                    d.isContact = true
                    d.isWallet = false
                    d.isSavedAccount = false
                    rootStoreMockup.accounts.itemChanged(d.displayAddress)
                    rootStoreMockup.savedAddresses.sourceModel.itemChanged(d.displayAddress)
                    contactsStoreMockup.myContactsModel.itemChanged(d.displayAddress)
                }
            }
            RadioButton {
                text: "wallet"
                checked: d.isWallet
                onClicked: {
                    d.isContact = false
                    d.isWallet = true
                    d.isSavedAccount = false
                    rootStoreMockup.accounts.itemChanged(d.displayAddress)
                    rootStoreMockup.savedAddresses.sourceModel.itemChanged(d.displayAddress)
                    contactsStoreMockup.myContactsModel.itemChanged(d.displayAddress)
                }
            }
            RadioButton {
                text: "saved address"
                checked: d.isSavedAccount
                onClicked: {
                    d.isContact = false
                    d.isWallet = false
                    d.isSavedAccount = true
                    rootStoreMockup.accounts.itemChanged(d.displayAddress)
                    rootStoreMockup.savedAddresses.sourceModel.itemChanged(d.displayAddress)
                    contactsStoreMockup.myContactsModel.itemChanged(d.displayAddress)
                }
            }
            RadioButton {
                text: "unkown"
                onClicked: {
                    d.isContact = false
                    d.isWallet = false
                    d.isSavedAccount = false
                    rootStoreMockup.accounts.itemChanged(d.displayAddress)
                    rootStoreMockup.savedAddresses.sourceModel.itemChanged(d.displayAddress)
                    contactsStoreMockup.myContactsModel.itemChanged(d.displayAddress)
                }
            }
            Label {
                text: "Name:"
            }
            RowLayout {
                TextField {
                    text: d.addressName
                    onTextChanged: d.addressName = text
                }
            }
            Label {
                text: "Address prefix:"
            }
            RowLayout {
                TextField {
                    text: d.addressPrefixString
                    onTextChanged: d.addressPrefixString = text
                }
                CheckBox {
                    text: "Show"
                    checked: d.showPrefix
                    onCheckedChanged: d.showPrefix = checked
                }
            }
        }
    }
}

// category: Wallet
