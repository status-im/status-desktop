import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.popups 1.0
import utils 1.0

import Storybook 1.0
import StubDecorators 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: invideFriendsPopup.open()
        }

        UtilsDecorator {
            id: utilsStub
        }


        InviteFriendsToCommunityPopup {
            id: invideFriendsPopup
            parent: parent
            modal: false
            anchors.centerIn: parent

            community: ({
                id: "communityId",
                name: "community-name"
            })

            rootStore: QtObject {
                function communityHasMember(communityId, pubKey) {
                    return false
                }
            }

            communitySectionModule: QtObject {
                function inviteUsersToCommunity(keys, message) {
                    logs.logEvent("communitySectionModule::inviteUsersToCommunity",
                                  ["keys", "message"], arguments)
                }
            }

            contactsStore: QtObject {
                readonly property ListModel myContactsModel: ListModel {
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
                                pubKey: key
                            })
                        }
                    }
                }
            }

            Component.onCompleted: open()
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
