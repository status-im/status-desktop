import QtQuick 2.13

QtObject {
    id: root

    property var messageModule

    function getMessageByIdAsJson (id) {
        if(!messageModule)
            return false

        let jsonObj = messageModule.getMessageByIdAsJson(id)
        let obj = JSON.parse(jsonObj)
        if (obj.error) {
            console.debug("error parsing message for index: ", id, " error: ", obj.error)
            return false
        }

        return obj
    }

    function getMessageByIndexAsJson (index) {
        if(!messageModule)
            return false

        let jsonObj = messageModule.getMessageByIndexAsJson(index)
        let obj = JSON.parse(jsonObj)
        if (obj.error) {
            console.debug("error parsing message for index: ", index, " error: ", obj.error)
            return false
        }

        return obj
    }
}
