import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Core.Theme

import AppLayouts.Communities.controls

import Storybook

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
