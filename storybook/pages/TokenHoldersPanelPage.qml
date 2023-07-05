import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1

import mainui 1.0

import AppLayouts.Communities.panels 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        TokenHoldersPanel {
            width: 568
            height: 364
            anchors.centerIn: parent
            tokenName: "Aniversary"
            model: TokenHoldersModel {}
            isSelectorMode: editorSelectorMode.checked
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        CheckBox {
            id: editorSelectorMode

            text: "Is selector mode?"
            checked: true
        }
    }
}

// category: Panels
