import QtQuick 2.14
import QtQuick.Controls 2.14

import shared.controls 1.0
import shared.stores 1.0

import utils 1.0

Pane {
    QtObject {
        id: userProfileInst

        Component.onCompleted: RootStore.userProfileInst = userProfileInst
    }

    QtObject {
        id: chatSectionChatContentInputArea
    }

    QtObject {
        id: mainModule

        signal resolvedENS
    }

    QtObject {
        id: globalUtilsInst

        function isCompressedPubKey() {
            return true
        }

        function getCompressedPk(publicKey) {
            return "zx3sh" + publicKey
        }

        Component.onCompleted: Utils.globalUtilsInst = globalUtilsInst
    }

    QtObject {
        id: mainModuleInst

        function isCompressedPubKey() {
            return true
        }

        function getContactDetailsAsJson() {
            return JSON.stringify({
                alias: "alias",
                isAdded: false
            })
        }

        Component.onCompleted: Utils.mainModuleInst = mainModuleInst
    }

    ContactsListAndSearch {
        anchors.fill: parent

        community: ({ id: "communityId" })

        contactsStore: QtObject {
            readonly property ListModel myContactsModel: ListModel {
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x1"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: "l1"
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x2 sdfsd"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x3 xcvxcv"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5e"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drtew5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5e"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drtew5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
            }
        }
    }
}

// category: Components
