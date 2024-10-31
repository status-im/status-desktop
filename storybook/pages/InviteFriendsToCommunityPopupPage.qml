import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Communities.popups 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores
import utils 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    property bool communitiesModuleReady: false

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: loader.item.open()
        }

        QtObject {
            function shareCommunityUrlWithData(communityId) {
                return "status-app:/"+communityId
            }

            Component.onCompleted: {
                communitiesModuleReady = true
                Utils.communitiesModuleInst = this
            }
            Component.onDestruction: {
                communitiesModuleReady = false
                Utils.communitiesModuleInst = {}
            }
        }

        Loader {
            id: loader
            active: communitiesModuleReady
            anchors.fill: parent

            sourceComponent: InviteFriendsToCommunityPopup {
                parent: parent
                modal: false
                anchors.centerIn: parent

                closePolicy: Popup.NoAutoClose

                community: ({
                    id: "communityId",
                    name: "community-name"
                })

                rootStore: AppLayoutStores.RootStore {
                    function communityHasMember(communityId, pubKey) {
                        return false
                    }
                }

                communitySectionModule: QtObject {
                    function shareCommunityToUsers(keys, message) {
                        logs.logEvent("communitySectionModule::shareCommunityToUsers",
                                      ["keys", "message"], arguments)
                    }
                }

                contactsModel: ListModel {
                    Component.onCompleted: {
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

                Component.onCompleted: open()
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2927%3A343592
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2990%3A353179
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2927%3A344073
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4291%3A385536
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=4295%3A385958
