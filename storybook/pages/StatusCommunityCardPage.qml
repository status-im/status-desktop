import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property string source: `
        import QtQml 2.14
        import StatusQ.Components 0.1
        Component {
            StatusCommunityCard {
               name: nameTextField.text
            }
        }
    `

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        HotLoader {
            id: loader

            anchors.centerIn: parent
            source: sourceCodeBox.sourceCode

            Connections {
                target: loader.item

                function onClicked() {
                    logs.logEvent("StatusCommunityCard::clicked",
                                  ["communityId"], arguments)
                }
            }
        }

        Pane {
            anchors.fill: parent
            visible: !!loader.errors

            CompilationErrorsBox {
                anchors.fill: parent
                errors: loader.errors
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        RowLayout {
            anchors.fill: parent

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent

                    TextField {
                        id: nameTextField
                        text: "Card name!"
                    }
                }
            }

            SourceCodeBox {
                id: sourceCodeBox

                Layout.preferredWidth: root.width / 2
                Layout.fillHeight: true

                sourceCode: root.source
                hasErrors: !!loader.errors
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416159
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416160
