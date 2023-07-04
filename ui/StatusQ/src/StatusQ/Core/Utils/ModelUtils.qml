pragma Singleton

import QtQuick 2.14

import StatusQ.Internal 0.1 as Internal

QtObject {
    function get(model, index, role = "") {
        if (role)
            return Internal.ModelUtils.get(model, index, role)
        else
            return Internal.ModelUtils.get(model, index)
    }

    function getByKey(model, keyRole, keyValue, role = "") {
        const idx = indexOf(model, keyRole, keyValue)

        if (idx === -1)
            return null

        return get(model, idx, role)
    }

    function modelToArray(model, roles) {
        if (!model)
            return []

        const count = model.rowCount()
        const array = []

        for (let i = 0; i < count; i++) {
            const modelItem = Internal.ModelUtils.get(model, i)
            const arrayItem = {}

            roles.forEach(role => {
                const entry = modelItem[role]

                if (entry !== undefined)
                    arrayItem[role] = entry
            })

            array.push(arrayItem)
        }

        return array
    }

    function modelToFlatArray(model, role) {
        return modelToArray(model, [role]).map(entry => entry[role])
    }

    function indexOf(model, role, key) {
        const count = model.rowCount()

        for (let i = 0; i < count; i++)
            if (Internal.ModelUtils.get(model, i, role) === key)
                return i

        return -1
    }

    function contains(model, roleName, value, mode = Qt.CaseSensitive) {
        return Internal.ModelUtils.contains(model, roleName, value, mode)
    }

    function checkItemsEquality(itemA, itemB, roles) {
        return roles.every((role) => itemA[role] === itemB[role])
    }

    function checkEqualityStrict(modelA, modelB, roles) {
        if (modelA === modelB)
            return true

        const countA = !!modelA ? modelA.rowCount() : 0
        const countB = !!modelB ? modelB.rowCount() : 0

        if (countA !== countB)
            return false

        if (countA === 0)
            return true

        for (let i = 0; i < countA; i++) {
            const itemA = Internal.ModelUtils.get(modelA, i)
            const itemB = Internal.ModelUtils.get(modelB, i)

            if (!checkItemsEquality(itemA, itemB, roles))
                return false
        }

        return true
    }

    function checkEqualitySet(modelA, modelB, roles) {
        if (modelA === modelB)
            return true

        const countA = !!modelA ? modelA.rowCount() : 0
        const countB = !!modelB ? modelB.rowCount() : 0

        if (countA !== countB)
            return false

        if (countA === 0)
            return true

        for (let i = 0; i < countA; i++) {
            const itemA = Internal.ModelUtils.get(modelA, i)
            let found = false

            for (let j = 0; j < countB; j++) {
                const itemB = Internal.ModelUtils.get(modelB, j)

                if (checkItemsEquality(itemA, itemB, roles))
                    found = true
            }

            if (!found)
                return false
        }

        return true
    }

    function roleNames(model) {
        return Internal.ModelUtils.roleNames(model)
    }
}
