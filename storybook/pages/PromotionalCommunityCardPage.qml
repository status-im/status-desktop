import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PromotionalCommunityCard {
            anchors.centerIn: parent

            onLearnMore: logs.logEvent("PromotionalCommunityCard::onLearnMore")
            onInitiateVote: logs.logEvent("PromotionalCommunityCard::onInitiateVote")
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}

// category: Components
// status: good
// https://www.figma.com/design/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?node-id=55170-330778&m=dev
