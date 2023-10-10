import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Control {
    id: root

    enum Mode {
        Base,
        InProgress,
        Failed,
        Success,
        Aborted,
        Crashed
    }

    property int mode: TestRunnerControls.Mode.Base
    property int numberOfFailedTests: 0

    signal runClicked
    signal abortClicked

    contentItem: RowLayout {
        id: testingRow

        states: [
            State {
                when: root.mode === TestRunnerControls.Mode.Base

                PropertyChanges {
                    target: button
                    text: "Run tests"
                }

                PropertyChanges {
                    target: label
                    visible: false
                }
            },
            State {
                when: root.mode === TestRunnerControls.Mode.InProgress

                PropertyChanges {
                    target: label
                    text: "Running tests"
                }
                PropertyChanges {
                    target: progressBar
                    visible: true
                }
                PropertyChanges {
                    target: button
                    text: "Abort"

                    onClicked: root.abortClicked()
                }
            },
            State {
                when: root.mode === TestRunnerControls.Mode.Failed

                PropertyChanges {
                    target: label
                    color: "darkred"
                    text: `Tests failed (${root.numberOfFailedTests})`
                }
            },
            State {
                when: root.mode === TestRunnerControls.Mode.Success

                PropertyChanges {
                    target: label
                    color: "darkgreen"
                    text: "Tests passed"
                }
            },
            State {
                when: root.mode === TestRunnerControls.Mode.Aborted

                PropertyChanges {
                    target: label
                    color: "darkred"
                    text: "Tests aborted"
                }
            },
            State {
                when: root.mode === TestRunnerControls.Mode.Crashed

                PropertyChanges {
                    target: label
                    color: "darkred"
                    text: "Tests crashed (segfault)"
                }
            }
        ]

        Label {
            id: label

            objectName: "label"
        }

        ProgressBar {
            id: progressBar

            objectName: "progressBar"

            visible: false
            indeterminate: true
            width: 50
        }

        ToolButton {
            id: button

            objectName: "button"

            text: "Re-run tests"

            onClicked: root.runClicked()
        }
    }
}
