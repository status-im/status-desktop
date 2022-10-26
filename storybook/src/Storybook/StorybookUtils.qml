pragma Singleton
import QtQml 2.14

QtObject {
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
