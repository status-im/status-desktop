import QtQuick
import QtQuick.Controls

import QtTest

import StatusQ

import SortFilterProxyModel
import AppLayouts.Communities.views

import Models

Item {

    id: root
    width: 600
    height: controlUnderTest ? controlUnderTest.implicitHeight : 800

    Component {
        id: componentUnderTest

        OwnerTokenWelcomeView {

            anchors.fill: parent

            communityLogo: ModelsData.icons.superRare
            communityColor: "pink"
            communityName: "SuperRare"
        }
    }

    property OwnerTokenWelcomeView name: OwnerTokenWelcomeView
    property var controlUnderTest

    SignalSpy {
        id: nextClickSpy
        target: controlUnderTest
        signalName: "nextClicked"
    }

    TestCase {
        name: "OwnerTokenWelcomeView"
        when: windowShown

        function init() {
            nextClickSpy.clear()
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function htmlToPlainText(html) {
            return html.replace(/<[^>]+>/g, "")
        }

        function test_ui_elements() {
            waitForRendering(controlUnderTest)

            const introText = findChild(controlUnderTest, "introPanelText")
            const ownerInfoPanel = findChild(controlUnderTest,
                                             "infoPanel_owner")
            const masterInfoPanel = findChild(controlUnderTest,
                                              "infoPanel_master")

            verify(introText !== null, "Intro text is missing")
            verify(ownerInfoPanel !== null, "Owner info panel is missing")
            verify(masterInfoPanel !== null, "Master info panel is missing")

            compare(htmlToPlainText(introText.text.trim().split(/\s+/).slice(
                                        0, 5).join(" ")),
                    "Your Owner token will give")
            compare(findChild(ownerInfoPanel, "Checklist").count, 4)
            compare(findChild(masterInfoPanel, "Checklist").count, 5)
        }

        function test_next_button() {

            const nextButton = findChild(controlUnderTest,
                                         "welcomeViewNextButton")

            verify(nextButton !== null, "Next button should be present")
            compare(nextButton.text, "Next")

            mouseClick(nextButton, Qt.LeftButton)
            tryCompare(nextClickSpy, "count", 1)
        }
    }
}
