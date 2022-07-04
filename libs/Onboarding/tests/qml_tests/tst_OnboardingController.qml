import QtQuick
import QtQml
import QtTest

import Status.Onboarding

import Status.TestHelpers

/**!
 * \todo use mocked values
 */
Item {
    id: root
    width: 400
    height: 300

    Component {
        id: onboardingDepsComponent

        Item {
            OnboardingModule {
                id: module

                userDataPath: "/tmp/StatusTests/demo"
            }

            // TODO: fix error "unable to assign Status::Onboarding::OnboardingController to Status::Onboarding::OnboardingController" then enable typed properties
            readonly property var /*OnboardingController*/ controller: module.controller
            readonly property var /*UserAccountsModel*/ accounts: controller.accounts
        }
    }

    Loader {
        id: testLoader

        anchors.fill: parent
        active: false
    }

    TestCase {
        id: qmlWarningsTest

        name: "TestQmlWarnings"

        when: windowShown

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
        }

        function cleanup() {
            testLoader.active = false
        }

        //
        // Tests

        function test_moduleInitialization() {
            testLoader.sourceComponent = onboardingDepsComponent
            testLoader.active = true
            verify(waitForRendering(testLoader.item))
            testLoader.active = false
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

//    TestCase {
//        id: qmlBenchmarks

//        name: "QmlBenchmarks"

//        function benchmark_loadAndUnloadModule() {
//            skip("Enable benchmarking after integrating it with reporting in CI")
//            testLoader.sourceComponent = onboardingDepsComponent
//            testLoader.active = true
//            testLoader.active = false
//        }
//    }

    MonitorQtOutput {
        id: qtOuput
    }
}
