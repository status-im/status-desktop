import QtQml 2.15

QtObject {
    id: root

    property string figmaToken

    readonly property QtObject _d: QtObject {
        id: d

        readonly property var linksMap: new Map()

        function createKey(file, nodeId) {
            return file + "/" + nodeId
        }
    }

    function getImageUrl(figmaLink, cb) {
        const { file, nodeId } = FigmaUtils.decomposeLink(figmaLink)
        const key = d.createKey(file, nodeId);

        if (d.linksMap.has(key)) {
            cb(d.linksMap.get(key))
        } else {
            FigmaUtils.getLinks(root.figmaToken, file, [nodeId],
                                (err, result) => {
                if (err)
                    return cb(null)

                for (const value of Object.values(result)) {
                    d.linksMap.set(key, value)
                    return cb(value)
                }
            })
        }
    }
}
