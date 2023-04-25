import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        CommunityAirdropsSettingsPanel {
            anchors.fill: parent
            anchors.topMargin: 50
            assetsModel: AssetsModel {}
            collectiblesModel: CollectiblesModel {}
            membersModel: ListModel {}

            onAirdropClicked: logs.logEvent("CommunityAirdropsSettingsPanel::onAirdropClicked")
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText
    }
}
