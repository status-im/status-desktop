import QtQuick 2.13

QtObject {
    id: root

    property var usersModule
    property var usersModel

    onUsersModuleChanged: {
        if(!usersModule)
            return
        root.usersModel = usersModule.model
    }
}
