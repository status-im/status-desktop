import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Models 1.0
import Storybook 1.0

import utils 1.0
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.panels 1.0

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
