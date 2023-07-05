import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1

import Models 1.0
import Storybook 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            spacing: 50
            anchors.centerIn: parent

            StatusInfoBoxPanel {
                Layout.preferredWidth: slider.value

                title: "Get started"
                text: ModelsData.descriptions.ownerTokenInfo
                buttonText: "Mint Owner token"

                onClicked: logs.logEvent("StatusInfoBoxPanel::onClicked --> First Panel")
            }

            StatusInfoBoxPanel {
                Layout.preferredWidth: slider.value

                title: "No hodlers just yet"
                text: ModelsData.descriptions.airdropInfo
                buttonText: "Airdrop"

                onClicked: logs.logEvent("StatusInfoBoxPanel::onClicked --> Second Panel")
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.fillWidth: true
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Panel width:"
            }

            Slider {
                id: slider
                value: 700
                from: 300
                to: 600
            }
        }

    }
}
