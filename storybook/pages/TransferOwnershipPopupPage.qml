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

            TransferOwnershipPopup {
                id: dialog

                anchors.centerIn: parent

                communityName: communityNameText.text
                communityLogo: ModelsData.collectibles.doodles
                token: TokenObject {
                    name: "Owner-CatsComm"
                    symbol: "OWNCAT"
                    accountAddress: "0x012304123"
                    chainId: 1
                    artworkSource: ModelsData.collectibles.doodles
                }

                onCancelClicked: logs.logEvent("TransferOwnershipPopup::onCancelClicked")
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

            Label {
                text: "Community Logo"
                font.bold: true
            }

            RadioButton {
                id: doodleLogo

                text: "Doodle"
                checked: true

                onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.doodles
            }

            RadioButton {
                id: manaLogo

                text: "Mana"

                onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.mana
            }

            RadioButton {
                id: superRareLogo

                text: "Status"

                onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.custom
            }
        }
    }
}

// category: Popups
