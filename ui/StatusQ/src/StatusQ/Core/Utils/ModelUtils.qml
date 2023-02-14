pragma Singleton

import QtQuick 2.14

QtObject {
    function modelToArray(model, roles) {
        if (!model)
            return []

        const count = model.count
        const array = []

        for (let i = 0; i < count; i++) {
            const modelItem = model.get(i)
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

    function indexOf(model, role, key) {
        const count = model.count

        for (let i = 0; i < count; i++)
            if (model.get(i)[role] === key)
                return i

        return -1
    }

    function checkItemsEquality(itemA, itemB, roles) {
        return roles.every((role) => itemA[role] === itemB[role])
    }

    function checkEqualityStrict(modelA, modelB, roles) {
        if (modelA === modelB)
            return true

        const countA = modelA === null ? 0 : modelA.rowCount()
        const countB = modelB === null ? 0 : modelB.rowCount()

        if (countA !== countB)
            return false

        if (countA === 0)
            return true

        for (let i = 0; i < countA; i++) {
            const itemA = modelA.get(i)
            const itemB = modelB.get(i)

            if (!checkItemsEquality(itemA, itemB, roles))
                return false
        }

        return true
    }

    function checkEqualitySet(modelA, modelB, roles) {
        if (modelA === modelB)
            return true

        const countA = modelA === null ? 0 : modelA.rowCount()
        const countB = modelB === null ? 0 : modelB.rowCount()

        if (countA !== countB)
            return false

        if (countA === 0)
            return true

        for (let i = 0; i < countA; i++) {
            const itemA = modelA.get(i)
            let found = false

            for (let j = 0; j < countB; j++) {
                const itemB = modelB.get(j)

                if (checkItemsEquality(itemA, itemB, roles))
                    found = true
            }

            if (!found)
                return false
        }

        return true
    }
}
