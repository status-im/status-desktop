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
}
