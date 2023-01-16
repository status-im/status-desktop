pragma Singleton

import QtQml 2.14

import Monitoring 1.0

QtObject {
    function typeName(obj) {
        const type = Monitor.typeName(obj)

        if (type === "QJSValue")
            return typeof obj

        return type
    }

    function valueToString(val) {
        if (val === undefined)
            return "undefined"

        if (val === null)
            return "null"

        const str = val.toString()

        if (typeof val === "string")
            return `"${str}"`

        if (typeof val !== "object")
            return str

        const bracketPos = str.indexOf("(")

        if (bracketPos === -1)
            return str

        return str.substring(bracketPos + 1, str.length - 1)
    }

    function contextPropertyBindingHelper(name, parent) {
        return Qt.createQmlObject(
                              `import QtQml 2.14; QtObject { readonly property var value: ${name} }`,
                              parent, `ctxPropHelperSnippet_${name}`)
    }
}
