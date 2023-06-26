import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.views 1.0

import Models 1.0
import Storybook 1.0


SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

            PermissionsView {
                anchors {
                    fill: parent
                    margins: 50
                }

                permissionsModel: ListModel {
                    id: permissionsModel

                    Component.onCompleted: append(PermissionsModel.permissionsModelData)
                }

                assetsModel: AssetsModel {
                    id: assetsModel
                }

                collectiblesModel: CollectiblesModel {
                    id: collectiblesModel
                }

                channelsModel: ChannelsModel {
                    id: channelsModel
                }

                communityDetails: QtObject {
                    readonly property string name: "Socks"
                    readonly property string image: ModelsData.icons.socks
                    readonly property string color: "red"
                }

                function log(method, index) {
                    logs.logEvent(`PermissionsView::${method} - index: ${index}`)
                }

                onEditPermissionRequested: log("editPermissionRequested", index)
                onRemovePermissionRequested: log("removePermissionRequested", index)
                onDuplicatePermissionRequested: log("duplicatePermissionRequested", index)
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        CommunityPermissionsSettingsPanelEditor {
            anchors.fill: parent
            model: permissionsModel

            assetKeys: assetsModel.data.map(asset => asset.key)
            collectibleKeys: collectiblesModel.data.map(collectible => collectible.key)
            channelKeys: {
                const array = ModelUtils.modelToArray(channelsModel,
                                                      ["itemId", "isCategory"])
                const channelsOnly = array.filter(channel => !channel.isCategory)

                return channelsOnly.map(channel => channel.itemId)
            }
        }
    }
}




