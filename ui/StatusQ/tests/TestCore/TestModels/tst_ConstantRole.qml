import QtQml 2.15
import QtQuick 2.15
import QtTest 1.15

import SortFilterProxyModel 0.2

import StatusQ 0.1

Item {
    id: root

    Component {
        id: testComponent

        QtObject {
            property int d: 0

            readonly property ListModel source: ListModel {
                ListElement { a: 1; b: 2; c: 3 }
            }

            readonly property ConstantRole constantRole: constantRole

            readonly property SortFilterProxyModel model: SortFilterProxyModel {
                id: testModel

                sourceModel: ListModel {
                    ListElement { a: 1; b: 2; c: 3 }
                }

                proxyRoles: ConstantRole {
                    id: constantRole

                    name: "constantRole"
                    value: 42
                }
            }

            readonly property Instantiator instantiator: Instantiator {
                model: testModel

                QtObject {
                    property int constantRole: model.constantRole
                }
            }

            readonly property SignalSpy dataChangedSignalSpy: SignalSpy {
                target: testModel
                signalName: "dataChanged"
            }

            readonly property SignalSpy modelResetSignalSpy: SignalSpy {
                target: testModel
                signalName: "modelReset"
            }
        }
    }

    TestCase {
        name: "ConstantRole"

        function test_constantRoleValue() {
            const obj = createTemporaryObject(testComponent, root)

            const instantiator = obj.instantiator
            const listModel = obj.source

            compare(instantiator.object.constantRole, 42)
            compare(obj.dataChangedSignalSpy.count, 0)

            obj.constantRole.value = 43

            compare(instantiator.object.constantRole, 43)
            compare(obj.dataChangedSignalSpy.count, 1)
            compare(obj.modelResetSignalSpy.count, 0)
        }
    }
}
