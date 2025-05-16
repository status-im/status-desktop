import QtQuick 2.15
import QtQuick.Controls 2.15

import QtTest 1.15

import StatusQ 0.1

import SortFilterProxyModel 0.2
import AppLayouts.Communities.views 1.0

import Models 1.0

Item {

    id: root
    width: 600
    height: 800

    Component {
        id: componentUnderTest

        OwnerTokenWelcomeView {

            anchors.fill: parent

            communityLogo: ModelsData.icons.superRare
            communityColor: "Light pink"
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

        function getModelLength(model) {
            return JSON.parse(JSON.stringify(model)).length;
        }



        function test_ui_elements() {
            waitForRendering(controlUnderTest)

            const introText = findChild(controlUnderTest, "introPanelText")
            const ownerInfoPanel = findChild(controlUnderTest, "infoPanel_owner")
            const masterInfoPanel = findChild(controlUnderTest, "infoPanel_master")
            const nextButton = findChild(controlUnderTest, "welcomeViewNextButton")


            compare(htmlToPlainText(introText.text.trim().split(/\s+/).slice(0, 5).join(" ")), "Your Owner token will give")
            compare(getModelLength(ownerInfoPanel.checkersModel), 4)
            compare(getModelLength(masterInfoPanel.checkersModel), 5)

            verify(nextButton !== null, "Next button should be present")
            compare(nextButton.text, "Next")

            mouseClick(nextButton, Qt.LeftButton)
            tryCompare(nextClickSpy, "count", 1)

        }
    }
}
