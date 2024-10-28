import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Chat.panels 1.0
import StatusQ 0.1

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

SplitView {
    Logs { id: logs }

    orientation: Qt.Vertical

    UsersModel {
        id: model
    }

    UserListPanel {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        label: "Some label"

        usersModel: SortFilterProxyModel {
            sourceModel: model

            proxyRoles: FastExpressionRole {
                name: "compressedKey"
                expression: "compressed"
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

// category: Panels
