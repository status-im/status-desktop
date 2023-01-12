pragma Singleton

import QtQml 2.14

QtObject {
    readonly property QtObject _d: QtObject {
        id: d

        function getByKey(model, key) {
            for (let i = 0; i < model.count; i++) {
                const item = model.get(i)
                if (item.key === key)
                    return item
            }

            return null
        }
    }

    function getAssetByKey(assetsModel, key) {
        return d.getByKey(assetsModel, key)
    }

    function getCollectibleByKey(collectiblesModel, key) {
        for (let i = 0; i < collectiblesModel.count; i++) {
            const item = collectiblesModel.get(i)

            if (!!item.subItems) {
                const sub = d.getByKey(item.subItems, key)
                if (sub)
                    return sub
            } else if (item.key === key) {
                return item
            }
        }

        return null
    }
}
