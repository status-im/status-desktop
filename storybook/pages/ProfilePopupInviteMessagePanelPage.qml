import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Communities.panels 1.0
import utils 1.0

Item {
    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    QtObject {
        function getCompressedPk(publicKey) {
            return "compressed"
        }

        function isCompressedPubKey() {
            return true
        }

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
            Utils.mainModuleInst = this
            mainModuleReady = true
        }

        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Frame {
        anchors.centerIn: parent

        height: parent.height * 0.8
        width: parent.width * 0.8

        Loader {
            active: globalUtilsReady && mainModuleReady

            anchors.fill: parent

            sourceComponent: ProfilePopupInviteMessagePanel {
                id: panel

                contactsStore: QtObject {
                    readonly property ListModel myContactsModel: ListModel {
                        Component.onCompleted: {
                            const keys = []

                            for (let i = 0; i < 20; i++) {
                                const key = `pub_key_${i}`

                                append({
                                    isContact: true,
                                    onlineStatus: 1,
                                    displayName: `contact ${i}`,
                                    icon: "",
                                    colorId: "1",
                                    pubKey: key
                                })

                                keys.push(key)
                            }

                            panel.pubKeys = keys
                        }
                    }
                }
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4291%3A385536
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4295%3A385958
