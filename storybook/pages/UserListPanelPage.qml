import QtQuick 2.14
import QtQuick.Controls 2.14
import AppLayouts.Chat.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0
import StubDecorators 1.0

SplitView {
    id: root

    Logs { id: logs }
    UsersModel { id: model }
    UtilsDecorator {
        mainModule.getContactDetailsAsJson: function(publicKey, getVerificationRequest) {
            return JSON.stringify({ ensVerified: false })
        }
    }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        UserListPanel {
            anchors.fill: parent
            usersModel: model
            messageContextMenu: null
            label: "Some label"
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
