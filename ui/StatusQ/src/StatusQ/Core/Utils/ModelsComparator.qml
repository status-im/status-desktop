import QtQml 2.14

QtObject {
    property var modelA: null
    property var modelB: null

    property var roles: []
    property int mode: ModelsComparator.CompareMode.Strict

    readonly property alias equal: d.equal

    enum CompareMode {
        Strict, Set
    }

    readonly property QtObject _d: QtObject {
        id: d

        component ModelObserver: Connections {
            function onRowsInserted() {
                d.changeCounter++
            }

            function onRowsMoved() {
                d.changeCounter++
            }

            function onRowsRemoved() {
                d.changeCounter++
            }

            function onLayoutChanged() {
                d.changeCounter++
            }

            function onModelReset() {
                d.changeCounter++
            }

            function onDataChanged() {
                d.changeCounter++
            }
        }

        property int changeCounter: 0

        readonly property bool equal: checkEquality(modelA, modelB, roles, mode,
                                                    changeCounter)

        readonly property Connections observerA: ModelObserver {
            target: modelA
        }

        readonly property Connections observerB: ModelObserver {
            target: modelB
        }

        function checkEquality(modelA, modelB, roles, mode, dummy) {
            if (modelA === modelB)
                return true

            const countA = modelA === null ? 0 : modelA.rowCount()
            const countB = modelB === null ? 0 : modelB.rowCount()

            if (countA !== countB)
                return false

            if (countA === 0)
                return true

            if (mode === ModelsComparator.CompareMode.Strict)
                return checkEqualityStrict(modelA, modelB, roles)

            return checkEqualitySet(modelA, modelB, roles)
        }

        function checkEqualityStrict(modelA, modelB, roles) {
            const count = modelA.rowCount()

            for (let i = 0; i < count; i++) {
                const itemA = modelA.get(i)
                const itemB = modelB.get(i)

                if (!checkItemsEquality(itemA, itemB, roles))
                    return false
            }

            return true
        }

        function checkEqualitySet(modelA, modelB, roles) {
            const count = modelA.rowCount()

            for (let i = 0; i < count; i++) {
                const itemA = modelA.get(i)
                let found = false

                for (let j = 0; j < count; j++) {
                    const itemB = modelB.get(j)

                    if (checkItemsEquality(itemA, itemB, roles))
                        found = true
                }

                if (!found)
                    return false
            }

            return true
        }

        function checkItemsEquality(itemA, itemB, roles) {
            return roles.every((role) => itemA[role] === itemB[role])
        }
    }
}
