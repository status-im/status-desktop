import QtQuick
import QtQuick.Controls

import AppLayouts.Communities.panels

Item {
    Frame {
        anchors.centerIn: parent

        height: parent.height * 0.8
        width: parent.width * 0.8

        ProfilePopupInviteMessagePanel {
            id: panel

            anchors.fill: parent

            contactsModel: ListModel {
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
                            pubKey: key,
                            compressedKey: "zx3sh" + key,
                            colorHash: [
                                { colorId: i, segmentLength: i % 5 },
                                { colorId: i + 5, segmentLength: 3 },
                                { colorId: 19, segmentLength: 2 }
                            ]
                        })

                        keys.push(key)
                    }

                    panel.pubKeys = keys
                }
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4291%3A385536
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4295%3A385958
