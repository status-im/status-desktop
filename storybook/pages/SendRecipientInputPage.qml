import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Controls

import Storybook

import utils

import shared.popups.send.controls

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            color: Theme.palette.baseColor2

            SendRecipientInput {
                anchors.centerIn: parent
                interactive: ctrlInteractive.checked
                checkMarkVisible: ctrlCheckmark.checked
                loading: ctrlLoading.checked
                Component.onCompleted: forceActiveFocus()

                onClearClicked: logs.logEvent("SendRecipientInput::clearClicked")
                onValidateInputRequested: logs.logEvent("SendRecipientInput::validateInputRequested")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            ColumnLayout {
                TextEdit {
                    readOnly: true
                    selectByMouse: true
                    text: "valid address: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4"
                }

                Switch {
                    id: ctrlInteractive
                    text: "Interactive"
                    checked: true
                }

                Switch {
                    id: ctrlCheckmark
                    text: "Checkmark visible"
                    checked: false
                }

                Switch {
                    id: ctrlLoading
                    text: "Loading"
                }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=9707-106469&t=MeyLezc91kfFYcm9-0
// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=10259-120493&t=MeyLezc91kfFYcm9-0
// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=9019-88679&t=MeyLezc91kfFYcm9-0
// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=9707-105782&t=MeyLezc91kfFYcm9-0

