import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.panels 1.0

import StatusQ 0.1
import Storybook 1.0
import Models 1.0

import utils 1.0

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
