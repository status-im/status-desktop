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
            property int d: 1

            property alias sorterEnabled: sorter.enabled

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

                sorters: FastExpressionSorter {
                    id: sorter

                    expression: {
                        return d ? modelLeft.a < modelRight.a
                                 : modelLeft.a > modelRight.a
                    }

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
        name: "FastExpressionSorter"

        function test_basicSorting() {
            const obj = createTemporaryObject(testComponent, root)
            const count = obj.model.count

            compare(count, 7)
            verify(obj.observer.accessCounter
                   < count * Math.ceil(Math.log2(count)) * 2)

            compare(obj.model.get(0).a, 1)
            compare(obj.model.get(1).a, 2)
            compare(obj.model.get(6).a, 7)
        }

        function test_filteringAfterContextChange() {
            const obj = createTemporaryObject(testComponent, root)
            const count = obj.model.count

            obj.observer.accessCounter = 0

            obj.d = 0

            verify(obj.observer.accessCounter
                   < count * Math.ceil(Math.log2(count)) * 2)

            compare(obj.model.get(0).a, 7)
            compare(obj.model.get(1).a, 6)
            compare(obj.model.get(6).a, 1)
        }

        function test_enabled() {
            const obj = createTemporaryObject(testComponent, root,
                                              { sorterEnabled: false, d: 0 })
            compare(obj.observer.accessCounter, 0)

            compare(obj.model.get(0).a, 1)
            compare(obj.model.get(1).a, 2)
            compare(obj.model.get(6).a, 7)

            obj.sorterEnabled = true

            const count = obj.model.count
            verify(obj.observer.accessCounter
                   < count * Math.ceil(Math.log2(count)) * 2)

            compare(obj.model.get(0).a, 7)
            compare(obj.model.get(1).a, 6)
            compare(obj.model.get(6).a, 1)
        }
    }
}
