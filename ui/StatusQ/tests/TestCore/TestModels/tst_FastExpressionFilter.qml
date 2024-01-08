import QtQml 2.15
import QtQuick 2.15
import QtTest 1.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.TestHelpers 0.1

Item {
    id: root

    Component {
        id: testComponent

        QtObject {
            property int d: 0

            property alias filterEnabled: filter.enabled

            readonly property ListModel source: ListModel {
                id: listModel

                ListElement { a: 1; b: 11; c: 101 }
                ListElement { a: 2; b: 12; c: 102 }
                ListElement { a: 3; b: 13; c: 103 }
                ListElement { a: 4; b: 14; c: 104 }
                ListElement { a: 5; b: 15; c: 105 }
                ListElement { a: 6; b: 16; c: 106 }
                ListElement { a: 7; b: 17; c: 107 }
            }

            readonly property ModelAccessObserverProxy observer: ModelAccessObserverProxy {
                id: observerProxy

                property int accessCounter: 0

                sourceModel: listModel

                onDataAccessed: accessCounter++
            }

            readonly property SortFilterProxyModel model: SortFilterProxyModel {
                id: testModel

                sourceModel: observerProxy

                filters: FastExpressionFilter {
                    id: filter

                    expression: a > d && a < 5
                    expectedRoles: ["a"]
                }
            }

            readonly property SignalSpy rowsRemovedSpy: SignalSpy {
                target: testModel
                signalName: "rowsRemoved"
            }
        }
    }

    TestCase {
        name: "FastExpressionFilter"

        function test_basicFiltering() {
            const obj = createTemporaryObject(testComponent, root)

            compare(obj.model.count, 4)
            compare(obj.observer.accessCounter, 7)
        }

        function test_filteringAfterContextChange() {
            const obj = createTemporaryObject(testComponent, root)

            compare(obj.rowsRemovedSpy.count, 0)
            obj.d = 1
            compare(obj.rowsRemovedSpy.count, 1)

            compare(obj.observer.accessCounter, 14)
        }

        function test_enabled() {
            const obj = createTemporaryObject(testComponent, root,
                                              { filterEnabled: false })

            compare(obj.model.count, 7)
            compare(obj.observer.accessCounter, 0)

            obj.filterEnabled = true

            compare(obj.model.count, 4)
            compare(obj.observer.accessCounter, 7)
        }
    }
}
