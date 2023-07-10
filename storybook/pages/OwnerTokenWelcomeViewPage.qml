import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.views 1.0

import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0

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
