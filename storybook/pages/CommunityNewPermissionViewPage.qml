import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

import Models 1.0

Pane {
    id: root

    CommunityNewPermissionView {

        store: CommunitiesStore {
            readonly property var assetsModel: AssetsModel {}
            readonly property var collectiblesModel: CollectiblesModel {}
            readonly property var channelsModel: ChannelsModel {}
            readonly property var permissionConflict: QtObject {
                property bool exists: true
                property string holdings: "1 ETH"
                property string permissions: "View and Post"
                property string channels: "#general"

            }

            function editPermission(index, holdings, permissions, channels, isPrivate) {
                logs.logEvent("CommunitiesStore::editPermission - index: " + index)
            }

            function duplicatePermission(index) {
                logs.logEvent("CommunitiesStore::duplicatePermission - index: " + index)
            }

            function removePermission(index) {
                logs.logEvent("CommunitiesStore::removePermission - index: " + index)
            }
        }

        rootStore: QtObject {
            readonly property QtObject chatCommunitySectionModule: QtObject {
                readonly property var model: ChannelsModel {}
            }

            readonly property QtObject mainModuleInst: QtObject {

                readonly property QtObject activeSection: QtObject {
                    readonly property string name: "Socks"
                    readonly property string image: ModelsData.icons.socks
                    readonly property color color: "red"
                }
            }
        }
    }
}
