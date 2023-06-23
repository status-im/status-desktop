import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Communities.popups 1.0
import utils 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

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
                mainModuleReady = true
                Utils.mainModuleInst = this
            }
            Component.onDestruction: {
                mainModuleReady = false
                Utils.mainModuleInst = {}
            }
        }

        Loader {
            id: loader
            active: globalUtilsReady && mainModuleReady
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
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
