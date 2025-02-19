import QtQuick 2.14
import QtTest 1.15

import AppLayouts.Wallet.popups 1.0

import utils 1.0

import Models 1.0

Item {
    id: root
    width: 600
    height: 600

    Component {
        id: componentUnderTest
        NetworkSelectPopup {
            anchors.centerIn: parent
            flatNetworks: NetworksModel.flatNetworks
            visible: true
        }
    }

    SignalSpy {
        id: selectionChangedSpy
        target: controlUnderTest
        signalName: "onSelectionChanged"
    }

    property NetworkSelectPopup controlUnderTest: null

    TestCase {
        name: "NetworkSelectPopup"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            controlUnderTest.open()
            compare(controlUnderTest.opened, true)
            selectionChangedSpy.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            compare(controlUnderTest.width, 300)
            compare(controlUnderTest.height, controlUnderTest.contentHeight + controlUnderTest.padding * 2)
        }

        function test_selectionBindings() {
            //single selection - select using the selectio property
            compare(controlUnderTest.multiSelection, false)
            controlUnderTest.selection = [controlUnderTest.flatNetworks.get(0).chainId]
            compare(controlUnderTest.selection, [controlUnderTest.flatNetworks.get(0).chainId])
            compare(selectionChangedSpy.count, 1)

            //single selection - select using the view
            const secondDelegate = findChild(controlUnderTest.contentItem, "networkSelectorDelegate_" + controlUnderTest.flatNetworks.get(1).chainName)
            mouseClick(secondDelegate)
            compare(controlUnderTest.selection, [controlUnderTest.flatNetworks.get(1).chainId])
            compare(selectionChangedSpy.count, 2)

            // multi selection - select using selection property
            controlUnderTest.open()
            controlUnderTest.multiSelection = true
            controlUnderTest.selection = [controlUnderTest.flatNetworks.get(0).chainId, controlUnderTest.flatNetworks.get(1).chainId]
            compare(controlUnderTest.selection, [controlUnderTest.flatNetworks.get(0).chainId, controlUnderTest.flatNetworks.get(1).chainId])
            compare(selectionChangedSpy.count, 3)

            // multi selection - select using the view
            const thirdDelegate = findChild(controlUnderTest.contentItem, "networkSelectorDelegate_" + controlUnderTest.flatNetworks.get(2).chainName)
            mouseClick(thirdDelegate)
            compare(controlUnderTest.selection.sort(), [controlUnderTest.flatNetworks.get(0).chainId, controlUnderTest.flatNetworks.get(1).chainId, controlUnderTest.flatNetworks.get(2).chainId].sort())
            compare(selectionChangedSpy.count, 4)
        }

        function test_closeAfterSingleSelection() {
            compare(controlUnderTest.multiSelection, false)
            const secondDelegate = findChild(controlUnderTest.contentItem, "networkSelectorDelegate_" + controlUnderTest.flatNetworks.get(1).chainName)
            mouseClick(secondDelegate)
            compare(controlUnderTest.opened, false)

            controlUnderTest.open()
            controlUnderTest.multiSelection = true
            const thirdDelegate = findChild(controlUnderTest.contentItem, "networkSelectorDelegate_" + controlUnderTest.flatNetworks.get(2).chainName)
            mouseClick(thirdDelegate)
            compare(controlUnderTest.opened, true)
        }
    }
}