import QtQuick 2.15
import QtQuick.Controls 2.15

import QtTest 1.15

import AppLayouts.TradingCenter.controls 1.0

Item {
    id: root

    width: 800
    height: 600

    Component {
        id: paginatorCmp
        Paginator {
            pageSize: 20
            totalCount: 1230
        }
    }

    property Paginator controlUnderTest: null

    TestCase {
        name: "Paginator"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(paginatorCmp, root)
        }

        function test_initialState() {
            verify(!!controlUnderTest)

            compare(controlUnderTest.currentPage, 1, "Initial page should be 1")

            const previousButton = findChild(controlUnderTest, "previousButton")
            verify(!!previousButton)
            verify(!previousButton.enabled, "previousButton should be enabled")

            const nextButton = findChild(controlUnderTest, "nextButton")
            verify(!!nextButton)
            verify(nextButton.enabled, "nextButton should be disabled")

            // set total count < pageSize and check button behaviours
            controlUnderTest.totalCount = 11
            verify(!previousButton.enabled, "previousButton should be disabled")
            verify(!nextButton.enabled, "nextButton should be disabled")
        }

        function test_nextPage() {
            verify(!!controlUnderTest)

            let totalPages = Math.ceil(controlUnderTest.totalCount/controlUnderTest.pageSize)

            const nextButton = findChild(controlUnderTest, "nextButton")
            verify(!!nextButton)

            for (let i = 1; i< totalPages; i++) {
                if(i == totalPages) {
                    verify(!nextButton.enabled, "nextButton should be disabled")
                }
                else {
                    verify(nextButton.enabled, "nextButton should be enabled")
                    mouseClick(nextButton)
                    compare(controlUnderTest.currentPage, i+1, "After next page, current page should be page + 1")
                }
            }
        }

        function test_previousPage() {
            verify(!!controlUnderTest)

            const previousButton = findChild(controlUnderTest, "previousButton")
            verify(!!previousButton)
            verify(!previousButton.enabled, "previousButton should be disabled")

            const nextButton = findChild(controlUnderTest, "nextButton")
            verify(!!nextButton)
            mouseClick(nextButton)

            compare(controlUnderTest.currentPage, 2)
            verify(previousButton.enabled, "previousButton should be enabled    ")

            // click previous button
            mouseClick(previousButton)
            compare(controlUnderTest.currentPage, 1)
        }

        function test_page_numbers_if_pages_greater_than_5() {
            verify(!!controlUnderTest)

            let totalPages = Math.ceil(controlUnderTest.totalCount/controlUnderTest.pageSize)

            const pageNumbersRepeater = findChild(controlUnderTest, "pageNumbersRepeater")
            verify(!!pageNumbersRepeater)

            compare(pageNumbersRepeater.count, 7)

            compare(pageNumbersRepeater.model, [1, 2, 3, 4, 5, "...", totalPages])
        }

        function test_page_numbers_if_pages_less_than_5() {
            verify(!!controlUnderTest)

            controlUnderTest.totalCount = 75

            let totalPages = Math.ceil(controlUnderTest.totalCount/controlUnderTest.pageSize)

            const pageNumbersRepeater = findChild(controlUnderTest, "pageNumbersRepeater")
            verify(!!pageNumbersRepeater)

            compare(pageNumbersRepeater.count, totalPages)

            compare(pageNumbersRepeater.model, [1, 2, 3, 4])
        }
    }
}
