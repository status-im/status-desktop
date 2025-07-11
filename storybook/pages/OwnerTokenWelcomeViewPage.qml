import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Communities.views

import StatusQ.Core.Theme

import Storybook
import Models

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    OwnerTokenWelcomeView {
        id: view

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        padding: 50
        anchors.margins: 50
        communityLogo: doodles.checked ? ModelsData.collectibles.doodles : ModelsData.collectibles.mana
        communityColor: color1.checked ?  "#FFC4E9" : "#f44336"
        communityName: communityName.text

        onNextClicked: logs.logEvent("OwnerTokenWelcomeView::onNextClicked")
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            RowLayout {
                RadioButton {
                    id: color1

                    text: "Light pink"
                    checked: true
                }

                RadioButton {
                    text: "Orange"
                }
            }

            RowLayout {
                RadioButton {
                    id: doodles
                    text: "Doodles"
                    checked: true
                }

                RadioButton {
                    text: "Mana"
                }
            }

            RowLayout {
                Label {
                    text: "Community name:"
                }

                TextInput {
                    id: communityName
                    text: "Doodles"
                }
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=34794%3A590064&mode=design&t=eabTmd6JZbuycoy8-1
