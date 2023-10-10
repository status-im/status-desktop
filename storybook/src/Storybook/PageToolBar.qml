import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

ToolBar {
    id: root

    property string componentName

    property int figmaPagesCount: 0

    signal figmaPreviewClicked
    signal inspectClicked

    RowLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
        }

        TextField {
            text: `pages/${root.componentName}Page.qml`
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            selectByMouse: true
            readOnly: true
            background: null
        }

        ToolButton {
            text: "📋"

            ToolTip.timeout: 2000
            ToolTip.text: "Component name copied to the clipboard"

            TextInput {
                id: hiddenTextInput
                text: root.componentName
                visible: false
            }

            onClicked: {
                hiddenTextInput.selectAll()
                hiddenTextInput.copy()
                ToolTip.visible = true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ToolSeparator {}

        TestRunnerControls {
            id: testRunnerControls

            property var testProcess: null
            readonly property string testFileName: `tst_${root.componentName}.qml`

            onTestFileNameChanged: {
                if (testRunnerControls.testProcess)
                    testRunnerControls.testProcess.kill()

                testRunnerControls.mode = TestRunnerControls.Mode.Base
            }

            onRunClicked: {
                const testsCount = TestsRunner.testsCount(testFileName)

                if (testsCount === 0)
                    return noTestsDialog.open()

                testRunnerControls.mode = TestRunnerControls.Mode.InProgress

                const process = TestsRunner.runTests(testFileName)
                testRunnerControls.testProcess = process

                process.finished.connect((exitCode, exitStatus) => {
                    if (testRunnerControls.mode !== TestRunnerControls.Mode.InProgress)
                        return

                    if (exitStatus) {
                        testRunnerControls.mode = TestRunnerControls.Mode.Crashed
                        return
                    }

                    if (exitCode)
                        testRunnerControls.mode = TestRunnerControls.Mode.Failed
                    else
                        testRunnerControls.mode = TestRunnerControls.Mode.Success

                    testRunnerControls.numberOfFailedTests = exitCode
                })
            }

            onAbortClicked: {
                testRunnerControls.testProcess.kill()
                testRunnerControls.mode = TestRunnerControls.Mode.Aborted
            }
        }

        ToolSeparator {}

        ToolButton {
            id: openFigmaButton

            text: `Figma designs (${root.figmaPagesCount})`

            onClicked: root.figmaPreviewClicked()
        }

        ToolSeparator {}

        ToolButton {
            text: "Inspect (Ctrl+Shift+I)"

            Layout.rightMargin: parent.spacing

            onClicked: root.inspectClicked()
        }
    }

    Dialog {
        id: noTestsDialog

        anchors.centerIn: Overlay.overlay

        title: "No tests found"
        standardButtons: Dialog.Ok

        Label {
            // check on visible used as a workaround to avoid warning about
            // binding loop on implicitWidth
            text: visible
                  ? `Please add valid tests to <b>${testRunnerControls.testFileName}</b> file`
                  : ""
        }
    }
}
