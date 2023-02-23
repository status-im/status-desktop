import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

import Storybook 1.0
import Models 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1


SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

            CommunityPermissionsView {
                anchors {
                    fill: parent
                    margins: 50
                }

                store: CommunitiesStore {
                    id: mockedCommunity

                    readonly property ListModel permissionsModel: ListModel {
                        Component.onCompleted: append(PermissionsModel.permissionsModelData)
                    }

                    readonly property AssetsModel assetsModel: AssetsModel {
                        id: assetsModel
                    }

                    readonly property CollectiblesModel collectiblesModel: CollectiblesModel {
                        id: collectiblesModel
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
                            readonly property string color: "red"
                        }
                    }
                }

                onEditPermissionRequested:
                    logs.logEvent("CommunityPermissionsView::editPermissionRequested - index: " + index)
                onRemovePermissionRequested:
                    logs.logEvent("CommunityPermissionsView::removePermissionRequested - index: " + index)
                onDuplicatePermissionRequested:
                    logs.logEvent("CommunityPermissionsView::duplicatePermissionRequested - index: " + index)
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
            model: mockedCommunity.permissionsModel

            assetKeys: assetsModel.data.map(asset => asset.key)
            collectibleKeys: collectiblesModel.data.map(collectible => collectible.key)
        }
    }
}




