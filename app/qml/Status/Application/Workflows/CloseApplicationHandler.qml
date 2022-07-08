import QtQml

QtObject {
    id: root

    required property bool quitOnClose

    signal hideApplication()

    function canApplicationClose() {
        if(root.quitOnClose) {
            root.hideApplication()
            return false
        }

        return true
    }
}
