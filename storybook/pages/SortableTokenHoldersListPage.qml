import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Chat.panels.communities 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    TokenHoldersModel {
        id: tokenHoldersModel
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SortableTokenHoldersList {
            id: holdersList

            anchors.fill: parent
            anchors.margins: 50

            model: TokenHoldersProxyModel {
                sourceModel: tokenHoldersModel

                sortBy: holdersList.sortBy
                sortOrder: holdersList.sorting === SortableTokenHoldersList.Sorting.Descending
                           ? Qt.DescendingOrder : Qt.AscendingOrder
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
