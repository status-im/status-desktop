import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import utils 1.0
import StubDecorators 1.0

Item {
    UtilsDecorator {
        globalUtils.getCompressedPk: function(publicKey) { return "compressed" }
        globalUtils.isCompressedPubKey: function() { return true }
        globalUtils.getColorHashAsJson: function(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }
    }

    Frame {
        anchors.centerIn: parent

        height: parent.height * 0.8
        width: parent.width * 0.8

        CommunityProfilePopupInviteMessagePanel {
            id: panel

            anchors.fill: parent
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
