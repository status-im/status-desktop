import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Communities.panels 1.0
import utils 1.0

Item {
    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({})
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Frame {
        anchors.centerIn: parent

        Loader {
            active: globalUtilsReady && mainModuleReady
            sourceComponent: ProfilePopupInviteFriendsPanel {
                id: panel

                community: ({ id: "communityId" })

                rootStore: QtObject {
                    function communityHasMember(communityId, pubKey) {
                        return false
                    }
                }

                contactsStore: QtObject {
                    readonly property ListModel myContactsModel: ListModel {
                        Component.onCompleted: {
                            const keys = []

                            for (let i = 0; i < 20; i++) {
                                const key = `pub_key_${i}`

                                append({
                                    alias: "",
                                    colorId: "1",
                                    displayName: `contact ${i}`,
                                    ensName: "",
                                    icon: "",
                                    isContact: true,
                                    localNickname: "",
                                    onlineStatus: 1,
                                    pubKey: key
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2927%3A343592
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2990%3A353179
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2927%3A344073
