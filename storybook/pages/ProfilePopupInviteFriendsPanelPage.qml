import QtQuick
import QtQuick.Controls

import AppLayouts.Communities.panels
import AppLayouts.stores as AppLayoutStores

Item {
    Frame {
        anchors.centerIn: parent

        ProfilePopupInviteFriendsPanel {
            communityId: "communityId"

            rootStore: AppLayoutStores.RootStore {
                function communityHasMember(communityId, pubKey) {
                    return false
                }
            }

            contactsModel: ListModel {
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
                            pubKey: key,
                            compressedKey: "zx3sh" + key,
                            colorHash: [
                                { colorId: i, segmentLength: i % 5 },
                                { colorId: i + 5, segmentLength: 3 },
                                { colorId: 19, segmentLength: 2 }
                            ]
                        })
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
