import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.15

import Storybook 1.0

TestCase {
    id: root

    name: "TestRunnerControlsTest"
    when: windowShown

    visible: true

    Component {
        id: testedComponent

        TestRunnerControls {}
    }

    Label {
        id: sampleLabel
    }

    readonly property color errorColor: "darkred"
    readonly property color successColor: "darkgreen"

    function test_states() {
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.Base
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, false)
            compare(progressBar.visible, false)
            compare(button.visible, true)
            compare(button.text, "Run tests")
        }
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.InProgress
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, true)
            compare(label.text, "Running tests")
            compare(label.color, sampleLabel.color)
            compare(progressBar.visible, true)
            compare(button.visible, true)
            compare(button.text, "Abort")
        }
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.Failed,
                numberOfFailedTests: 42
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, true)
            compare(label.text, "Tests failed (42)")
            compare(label.color, root.errorColor)
            compare(progressBar.visible, false)
            compare(button.visible, true)
            compare(button.text, "Re-run tests")
        }
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.Success
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, true)
            compare(label.text, "Tests passed")
            compare(label.color, root.successColor)
            compare(progressBar.visible, false)
            compare(button.visible, true)
            compare(button.text, "Re-run tests")
        }
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.Aborted
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, true)
            compare(label.text, "Tests aborted")
            compare(label.color, root.errorColor)
            compare(progressBar.visible, false)
            compare(button.visible, true)
            compare(button.text, "Re-run tests")
        }
        {
            const obj = createTemporaryObject(testedComponent, this, {
                mode: TestRunnerControls.Mode.Crashed
            })

            const label = findChild(obj, "label")
            const progressBar = findChild(obj, "progressBar")
            const button = findChild(obj, "button")

            compare(label.visible, true)
            compare(label.text, "Tests crashed (segfault)")
            compare(label.color, root.errorColor)
            compare(progressBar.visible, false)
            compare(button.visible, true)
            compare(button.text, "Re-run tests")
        }
    }
}
