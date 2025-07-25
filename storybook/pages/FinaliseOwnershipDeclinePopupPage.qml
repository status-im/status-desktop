import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import AppLayouts.Communities.popups
import AppLayouts.Communities.helpers

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            FinaliseOwnershipDeclinePopup {
                id: dialog

                anchors.centerIn: parent
                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false
                communityId: "ddls"

                communityName: communityNameText.text

                onDeclineClicked: logs.logEvent("FinaliseOwnershipDeclinePopup::onDeclineClicked")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Community Name"
                font.bold: true
            }

            TextInput {
                id: communityNameText

                text: "Doodles"

            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A93540&mode=design&t=olSRjSKm7CM2vv5O-1
