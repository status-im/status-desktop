import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Communities.panels

import StatusQ
import Storybook
import Models

import utils

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    TokenHoldersJoinModel {
        id: joinModel
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true



        SortableTokenHoldersList {
            id: holdersList

            anchors.fill: parent
            anchors.margins: 50

            model: TokenHoldersProxyModel {
                sourceModel: joinModel

                sortBy: holdersList.sortBy
                sortOrder: holdersList.sortOrder ? Qt.DescendingOrder : Qt.AscendingOrder
            }

            onClicked: logs.logEvent("holdersList.clicked: " + index)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Components
