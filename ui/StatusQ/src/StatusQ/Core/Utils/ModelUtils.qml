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
}
