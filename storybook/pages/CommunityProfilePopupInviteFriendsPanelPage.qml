import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import utils 1.0
import StubDecorators 1.0

Item {
    UtilsDecorator {
        globalUtils.isCompressedPubKey: function(publicKey) { return true }
        globalUtils.getCompressedPk: function(publicKey) { return "zx3sh" + publicKey }
        globalUtils.getColorHashAsJson: function(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }
    }

    SharedRootStoreDecorator {}

    Frame {
        anchors.centerIn: parent

        CommunityProfilePopupInviteFriendsPanel {
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
