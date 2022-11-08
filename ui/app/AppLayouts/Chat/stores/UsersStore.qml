import QtQuick 2.13

QtObject {
    id: root

    property var usersModule

    readonly property var usersModel: usersModule ? usersModule.model : null
    readonly property var temporaryModel: usersModule ? usersModule.temporaryModel : null

    function appendTemporaryModel(pubKey, displayName) {
        usersModule.appendTemporaryModel(pubKey, displayName)
    }
    function removeFromTemporaryModel(pubKey) {
        usersModule.removeFromTemporaryModel(pubKey)
    }
    function resetTemporaryModel() {
        usersModule.resetTemporaryModel()
    }
    function updateGroupMembers() {
        usersModule.updateGroupMembers()
    }
}
