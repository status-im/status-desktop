import QtQml
import QtQuick
import QtTest

import SortFilterProxyModel

import StatusQ
import StatusQ.Core.Utils

import StatusQ.TestHelpers

Item {
    id: root

    Component {
        id: testComponent

        QtObject {
            property int d: 0

            readonly property ListModel source: ListModel {
                id: listModel

                ListElement { a: 1; b: 2; c: 3 }
            }

            readonly property ModelAccessObserverProxy observer: ModelAccessObserverProxy {
                id: observerProxy

                property int accessCounter: 0

                sourceModel: listModel

                onDataAccessed: accessCounter++
            }

            readonly property FastExpressionRole expressionRole: expressionRole

            readonly property SortFilterProxyModel model: SortFilterProxyModel {
                id: testModel

                sourceModel: observerProxy

                proxyRoles: [
                    FastExpressionRole {
                        id: expressionRole

                        name: "expressionRole"
                        expression: a + model.b + (model.c ?? 0) + d + index

                        expectedRoles: ["a", "b"]
                    },
                    FastExpressionRole {
                        name: "expressionRole2"
                        expression: "staticRole"
                    }
                ]
            }

            readonly property Instantiator instantiator: Instantiator {
                model: testModel

                QtObject {
                    property string expressionRole: model.expressionRole
                }
            }

            readonly property SignalSpy modelSignalSpy: SignalSpy {
                target: testModel
                signalName: "dataChanged"
            }
        }
    }

    TestCase {
        name: "FastExpressionRole"

        function test_expressionRoleValue() {
            const obj = createTemporaryObject(testComponent, root)

            const instantiator = obj.instantiator
            const listModel = obj.source

            fuzzyCompare(instantiator.object.expressionRole, 3, 1e-7)
            listModel.setProperty(0, "b", 9)
            fuzzyCompare(instantiator.object.expressionRole, 10, 1e-7)
            obj.d = 42
            fuzzyCompare(instantiator.object.expressionRole, 52, 1e-7)
        }

        function test_expressionRoleAccessToSource() {
            const obj = createTemporaryObject(testComponent, root)

            const testModel = obj.model
            const observerProxy = obj.observer

            observerProxy.accessCounter = 0

            ModelUtils.get(testModel, 0, "expressionRole")
            compare(observerProxy.accessCounter, 2)

            ModelUtils.get(testModel, 0, "expressionRole2")
            compare(observerProxy.accessCounter, 2)
        }

        function test_expressionRoleAccessToSourceViaContextChange() {
            const obj = createTemporaryObject(testComponent, root)

            const testModel = obj.model
            const observerProxy = obj.observer

            const instantiator = obj.instantiator

            observerProxy.accessCounter = 0
            compare(obj.modelSignalSpy.count, 0)

            obj.d = 1

            compare(obj.modelSignalSpy.count, 1)
            compare(observerProxy.accessCounter, 4)
        }

        function test_expressionRoleChangeExpectedRoles() {
            const obj = createTemporaryObject(testComponent, root)

            const instantiator = obj.instantiator
            const expressionRole = obj.expressionRole

            fuzzyCompare(instantiator.object.expressionRole, 3, 1e-7)

            expressionRole.expectedRoles = ["a", "b", "c"]
            fuzzyCompare(instantiator.object.expressionRole, 6, 1e-7)

            expressionRole.expectedRoles = ["a", "b"]
            fuzzyCompare(instantiator.object.expressionRole, 3, 1e-7)
        }
    }
}
