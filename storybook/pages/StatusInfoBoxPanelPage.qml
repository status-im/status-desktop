import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

import Models
import Storybook

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
                buttonVisible: btnVisible.checked
                buttonEnabled: btnEnabled.checked

                onClicked: logs.logEvent("StatusInfoBoxPanel::onClicked --> First Panel")
            }

            StatusInfoBoxPanel {
                Layout.preferredWidth: slider.value

                title: "No hodlers just yet"
                icon: "settings"
                iconType: ctrlIconType.currentIndex
                text: ModelsData.descriptions.airdropInfo
                buttonText: "Airdrop"
                buttonVisible: btnVisible.checked
                buttonEnabled: btnEnabled.checked

                onClicked: logs.logEvent("StatusInfoBoxPanel::onClicked --> Second Panel")
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.fillWidth: true
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Panel width: "
                }

                Slider {
                    id: slider
                    value: 700
                    from: 300
                    to: 600
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Icon type: "
                }

                ComboBox {
                    id: ctrlIconType
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        { value: StatusInfoBoxPanel.Type.Info, text: "Info" },
                        { value: StatusInfoBoxPanel.Type.Danger, text: "Danger" },
                        { value: StatusInfoBoxPanel.Type.Success, text: "Success" },
                        { value: StatusInfoBoxPanel.Type.Warning, text: "Warning" }
                    ]
                }
            }

            CheckBox {
                id: btnVisible
                text: "Button visible"
                checked: true
            }

            CheckBox {
                id: btnEnabled
                text: "Button enabled"
                checked: true
            }
        }
    }
}

// category: Panels
