pragma Singleton
import QtQml 2.14

QtObject {
    function singleShotConnection(prop, handler) {
        const internalHandler = (...args) => {
            handler(...args)
            prop.disconnect(internalHandler)
        }
        prop.connect(internalHandler)
    }

    function getUniqueValuesFromModel(model, prop) {
        if (!model)
            return []

        const values = []
        for (let i = 0; i < model.count; i++)
            values.push(model.get(i)[prop])

        const onlyUnique = (value, index, self) => self.indexOf(value) === index
        return values.filter(onlyUnique)
    }

    function formatQmlCode(code) {
        code = code.replace(/^\n+/, "")
        code = code.replace(/\s+$/, "")

        const match = code.match(/^[ \t]*(?=\S)/gm)

        if (!match)
            return code

        const minIndent = match.reduce((r, a) => Math.min(r, a.length),
                                       Number.POSITIVE_INFINITY)

        if (minIndent === 0)
            return code

        const regex = new RegExp(`^[ \\t]{${minIndent}}`, "gm")
        return code.replace(regex, "")
    }
}
