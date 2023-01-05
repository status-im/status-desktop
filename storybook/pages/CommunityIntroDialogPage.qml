import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import shared.popups 1.0

SplitView {
    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

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

                onClicked: dialog.open()
            }

            CommunityIntroDialog {
                id: dialog

                anchors.centerIn: parent

                visible: true

                name: "test"
                introMessage: "Welcome to the Status CCs community. Only Status CCs are allowed in this community."
                imageSrc: ModelsData.icons.cryptoKitty

            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true
                text: "name"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: dialog.name
                onTextChanged: dialog.name = text
            }

            Label {
                Layout.fillWidth: true
                text: "intro message"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: dialog.introMessage
                onTextChanged: dialog.introMessage = text
            }

            CheckBox {
                text: "icon"
                checked: true
                onToggled: {
                    if (checked) {
                        dialog.imageSrc = ModelsData.icons.cryptoKitty
                    } else {
                        dialog.imageSrc = ""
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

