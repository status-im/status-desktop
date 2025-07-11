import QtQuick
import QtQuick.Controls

import StatusQ.Core

import mainui

import AppLayouts.Communities.panels

import Storybook
import Models

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
