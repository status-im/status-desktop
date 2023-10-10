import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ToolBar {
    id: root

    property string componentName
    property int figmaPagesCount: 0

    required property TestRunnerController testRunnerController

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

            readonly property string testFileName: `tst_${root.componentName}.qml`

            onTestFileNameChanged: {
                if (testRunnerController.running)
                    testRunnerController.abort()

                testRunnerControls.mode = TestRunnerControls.Mode.Base
            }

            Connections {
                target: testRunnerController

                function onStarted() {
                    testRunnerControls.mode = TestRunnerControls.Mode.InProgress
                }

                function onFinished(failedTests, aborted, crashed) {
                    if (testRunnerControls.mode !== TestRunnerControls.Mode.InProgress)
                        return

                    if (aborted) {
                        testRunnerControls.mode = TestRunnerControls.Mode.Aborted
                        return
                    }

                    if (crashed) {
                        testRunnerControls.mode = TestRunnerControls.Mode.Crashed
                        return
                    }

                    testRunnerControls.mode = failedTests
                            ? TestRunnerControls.Mode.Failed
                            : TestRunnerControls.Mode.Success

                    testRunnerControls.numberOfFailedTests = failedTests
                }
            }

            onRunClicked: {
                const testsCount = testRunnerController.getTestsCount(testFileName)

                if (testsCount === 0)
                    return noTestsDialog.open()

                testRunnerController.runTests(testFileName)
            }

            onAbortClicked: testRunnerController.abort()
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

        onAccepted: Qt.openUrlExternally(testRunnerController.getTestsPath())
        Component.onCompleted: standardButton(Dialog.Ok).text = "Open tests folder"
    }
}
