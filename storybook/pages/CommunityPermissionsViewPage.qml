import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

import Storybook 1.0
import Models 1.0
import StatusQ.Core.Theme 0.1

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
                    permissionsModel: PermissionsModel.permissionsModel

                    function duplicatePermission(index) {
                        logs.logEvent("CommunitiesStore::duplicatePermission - index: " + index)
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

                onEditPermission: logs.logEvent("CommunitiesStore::editPermission - index: " + index)
                onRemovePermission: logs.logEvent("CommunitiesStore::removePermission - index: " + index)

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
        }
    }
}




