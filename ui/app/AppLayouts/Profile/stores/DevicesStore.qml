import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var devicesModule

    property var devicesModel: devicesModule.model

    // Module Properties
    property bool isDeviceSetup: devicesModule.isDeviceSetup

    function setName(name) {
        return root.devicesModule.setName(name)
    }

    function syncAll() {
        root.devicesModule.syncAll()
    }

    function advertise() {
        root.devicesModule.advertise()
    }

    function enableDevice(installationId, enable) {
        root.devicesModule.enableDevice(installationId, enable)
    }
}
