import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.stores 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            CommunityPermissionsSettingsPanel {
                anchors {
                    fill: parent
                    topMargin: 50
                }
                store: CommunitiesStore {
                    tokensModel: TokensModel {}
                    collectiblesModel: CollectiblesModel {}
                    channelsModel: ChannelsModel {}

                    function editPermission(index) {
                        logs.logEvent("CommunitiesStore::editPermission - index: " + index)
                    }

                    function duplicatePermission(index) {
                        logs.logEvent("CommunitiesStore::duplicatePermission - index: " + index)
                    }

                    function removePermission(index) {
                        logs.logEvent("CommunitiesStore::removePermission - index: " + index)
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }
}
