pragma Singleton

import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject {
    function isVisual(item) {
        return item instanceof Text
                || item instanceof Rectangle
                || item instanceof Image
                || item instanceof TextEdit
                || item instanceof TextInput
                || item instanceof SpriteSequence
    }

    function baseName(item) {
        const fullName = item.toString()
        const underscoreIndex = fullName.indexOf("_")

        if (underscoreIndex !== -1)
            return fullName.substring(0, underscoreIndex)

        const bracketIndex = fullName.indexOf("(")

        if (bracketIndex !== -1)
            return fullName.substring(0, bracketIndex)

        return fullName
    }

    function baseTypeName(item) {
        if (item instanceof Text)
            return "Text"
        if (item instanceof Rectangle)
            return "Rectangle"
        if (item instanceof Image)
            return "Image"
        if (item instanceof TextEdit)
            return "TextEdit"
        if (item instanceof TextInput)
            return "TextInput"
        if (item instanceof SpriteSequence)
            return "SpriteSequence"

        if (item instanceof Control)
            return "Control"

        return ""
    }

    function trimQQuickPrefix(name) {
        if (name.startsWith("QQuick"))
            return name.substring(6)

        return name
    }

    function simpleName(item) {
        const name = trimQQuickPrefix(baseName(item))
        const base = baseTypeName(item)

        if (base)
            return `${name} [${base}]`

        return name
    }

    function findItemsByTypeName(root, typeName) {
        const items = []
        const stack = [root]

        while (stack.length) {
            const item = stack.pop()

            if (!item.visible || item.opacity === 0)
                continue

            const name = baseName(item)

            if (name === typeName) {
                items.push(item)
                continue
            }

            for (let i = 0; i < item.children.length; i++)
                stack.push(item.children[i])
        }

        return items
    }

    function pathToAncestor(item, ancestor) {
        const path = [item]

        while (path[path.length - 1].parent !== ancestor)
            path.push(path[path.length - 1].parent)

        return path
    }

    function lowestCommonAncestor(items, commonAncestor) {
        if (items.length === 0)
            return null

        const paths = items.map(item => pathToAncestor(item, commonAncestor))

        let candidate = null

        while (true) {
            const top = paths.map(path => path.pop())

            if (top.every(val => val && val === top[0]))
                candidate = top.shift()
            else
                return candidate
        }
    }
}
