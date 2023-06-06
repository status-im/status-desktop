import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Models 1.0
import Storybook 1.0

import utils 1.0
import AppLayouts.Chat.popups.community 1.0
import AppLayouts.Chat.panels.communities 1.0

SplitView {
    id: root

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        ChatPermissionQualificationPanel {
            anchors.centerIn: parent
            width: 500
            height: 40
            holdingsModel: PermissionsModel.longPermissionsModel
            assetsModel: AssetsModel {}
            collectiblesModel: CollectiblesModel {}
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
