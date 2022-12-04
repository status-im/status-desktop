import QtQuick 2.14

import utils 1.0

import NimModules 1.0

QtObject {
    id: root
    property GlobalUtils globalUtils: GlobalUtils {}
    property MainModule mainModule: MainModule {}

    Component.onCompleted: {
        Utils.globalUtilsInst = root.globalUtils
        Utils.mainModuleInst = root.mainModule
    }
}
