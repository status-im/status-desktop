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
                    isContact: true
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
            id: contactsStoreMockup
            readonly property var myContactsModel: QtObject {
                signal itemChanged(address: string)
            }

            function getContactPublicKeyByAddress(address) {
                return address.includes("0x29D7d1dd5B6f9C864d9db560D72a247c178aE86C") ? "zQ3shWU7xpM5YoG19KP5JDRiSs1AdWtjpnrWEerMkxfQnYo7x" : ""
            }
        }

        QtObject {
            id: mockupRootStore

            function getNameForAddress(address) {
                const nameList = [ 'Alice', 'Bob', 'Charlie', 'Dave', 'Eve','Frank', 'Grace', 'Hank', 'Iris', 'Jack' ];
                const randomIndex = Math.floor(Math.random() * nameList.length);
                return nameList[randomIndex];
            }

            function getNameForSavedWalletAddress(address) {
                if (address.includes("0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35")) {
                    return ""
                }

                return getNameForAddress(address)
            }
            function getEmojiForWalletAddress(address) {
                return '<img class="emoji" draggable="false" alt="??" src="' + Style.emoji("1f61b") + '?72x72" width="16" height="16" style="vertical-align: top"/>'
            }
            function getColorForWalletAddress(address) {
                return "blue"
            }
            function getNameForWalletAddress(address) {
                if (address.includes("0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35") || address.includes("0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc36")) {
                    return ""
                }
                return getNameForAddress(address)
            }
        }

        Loader {
            id: loader
            anchors.centerIn: parent
            width: 500
            active: root.globalUtilsReady && root.mainModuleReady
            sourceComponent: Column {
                id: content
                spacing: 0
                TransactionAddressTile {
                    title: "From"
                    width: parent.width
                    rootStore: mockupRootStore
                    contactsStore: contactsStoreMockup
                    addresses: [
                        "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B"
                    ]
                }
                TransactionAddressTile {
                    title: "To"
                    width: parent.width
                    rootStore: mockupRootStore
                    contactsStore: contactsStoreMockup
                    addresses: [
                        "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86C",
                        "eth:arb:opt:0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
                        "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
                        "eth:opt:arb:0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
                        "eth:opt:arb:0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B",
                        "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B",
                        "eth:opt:arb:0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc36"
                    ]
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        SplitView.fillWidth: true
    }
}
