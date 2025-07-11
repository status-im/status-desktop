pragma Singleton

import QtQuick

import QtQml

QtObject {
    function findTextItem(root, text) {
        for (let i = 0; i < root.children.length; i++) {
            const c = root.children[i]

            if (c instanceof Text && c.text === text)
                return c

            const sub = findTextItem(c, text)

            if (sub)
                return sub
        }

        return null
    }

    function findByType(root, type) {
        const children = []

        for (let i = 0; i < root.children.length; i++)
            children.push(root.children[i])

        while (children.length > 0) {
            const c = children.shift()

            if (c instanceof type)
                return c

            for (let i = 0; i < c.children.length; i++)
                children.push(c.children[i])
        }

        return null
    }
}
