import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import shared.popups

import Storybook

SplitView {

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popup.open()
        }

        ConfirmExternalLinkPopup {
            id: popup

            closePolicy: Popup.CloseOnEscape
            modal: false
            visible: true

            link: "https://etherscan.io/token/0xdac17f958d2ee523a220622064597c13d831ec7"
            domain: "etherscan.io"

            onOpenExternalLink: logs.logEvent("onOpenExternalLink called with link: " + link)
            onSaveDomainToUnfurledWhitelist: logs.logEvent("onSaveDomainToUnfurledWhitelist called with domain: " + domain)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Popups
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=27093-584044&m=dev
