import QtQuick 2.15
import QtQuick.Controls 2.15

import QtTest 1.15

import StatusQ.Core 0.1

import AppLayouts.Market.controls 1.0

Item {
    id: root

    width: 800
    height: 600

    Component {
        id: marketFooterCmp
        MarketFooter {
            width: parent.width
            pageSize: 20
            totalCount: 1230
            currentPage: 1
            onSwitchPage: currentPage = pageNumber
        }
    }

    property MarketFooter controlUnderTest: null

    SignalSpy {
        id: switchPageSpy
        target: root.controlUnderTest
        signalName: "switchPage"
    }

    TestCase {
        name: "MarketFooter"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(marketFooterCmp, root)
        }

        function cleanup() {
            switchPageSpy.clear()
        }

        function test_info_text() {
            verify(!!controlUnderTest)

            const infoText = findChild(controlUnderTest, "infoText")
            verify(!!infoText)
            const paginator = findChild(controlUnderTest, "paginator")
            verify(!!paginator)

            const startIndex = ((paginator.currentPage - 1) * controlUnderTest.pageSize) + 1
            const endIndex = Math.min(paginator.currentPage * controlUnderTest.pageSize, controlUnderTest.totalCount)

            compare(infoText.x, 0)
            compare(infoText.text, qsTr("Showing %1 to %2 of %3 results")
                    .arg(LocaleUtils.numberToLocaleString(startIndex))
                    .arg(LocaleUtils.numberToLocaleString(endIndex))
                    .arg(LocaleUtils.numberToLocaleString(controlUnderTest.totalCount)))
        }

        function test_paginator() {
            verify(!!controlUnderTest)

            const paginator = findChild(controlUnderTest, "paginator")
            verify(!!paginator)

            compare(paginator.x, Math.floor(controlUnderTest.width/2 - paginator.width/2))
            compare(paginator.currentPage, 1)

            const nextButton = findChild(paginator, "nextButton")
            verify(!!nextButton)
            const previousButton = findChild(paginator, "previousButton")
            verify(!!previousButton)
            const fifthButton = findChild(paginator, "numberButton_4")
            verify(!!fifthButton)

            mouseClick(nextButton)
            tryCompare(switchPageSpy, "count", 1)
            compare(switchPageSpy.signalArguments[0][0], 2)
            compare(controlUnderTest.currentPage, 2)

            switchPageSpy.clear()
            mouseClick(nextButton)
            tryCompare(switchPageSpy, "count", 1)
            compare(switchPageSpy.signalArguments[0][0], 3)
            compare(controlUnderTest.currentPage, 3)

            switchPageSpy.clear()
            mouseClick(previousButton)
            tryCompare(switchPageSpy, "count", 1)
            compare(switchPageSpy.signalArguments[0][0], 2)
            compare(controlUnderTest.currentPage, 2)

            switchPageSpy.clear()
            mouseClick(fifthButton)
            tryCompare(switchPageSpy, "count", 1)
            compare(switchPageSpy.signalArguments[0][0], 5)
            compare(controlUnderTest.currentPage, 5)
        }
    }
}
