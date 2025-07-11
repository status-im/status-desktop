import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Models
import Storybook

import utils
import AppLayouts.Communities.popups
import AppLayouts.Communities.panels

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

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2698%3A375926&t=iIeFeGOBx5BbbYJa-0
