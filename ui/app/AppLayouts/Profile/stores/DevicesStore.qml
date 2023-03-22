import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var devicesModule

    property var devicesModel: devicesModule ?  devicesModule.model : null

    // Module Properties
    property bool isDeviceSetup: devicesModule ? devicesModule.isDeviceSetup : false

    readonly property int localPairingState: devicesModule ? devicesModule.localPairingState : -1
    readonly property string localPairingError: devicesModule ? devicesModule.localPairingError : ""

    function loadDevices() {
        return root.devicesModule.loadDevices()
    }

    function setInstallationName(installationId, name) {
        return root.devicesModule.setInstallationName(installationId, name)
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

    function authenticateUser() {
        const keyUid = "" // TODO: Support Keycard
        root.devicesModule.authenticateUser(keyUid)
    }

    function validateConnectionString(connectionString) {
        return root.devicesModule.validateConnectionString(connectionString)
    }

    function getConnectionStringForBootstrappingAnotherDevice(keyUid, password) {
        return root.devicesModule.getConnectionStringForBootstrappingAnotherDevice(keyUid, password)
    }

    function inputConnectionStringForBootstrapping(connectionString) {
        return root.devicesModule.inputConnectionStringForBootstrapping(connectionString)
    }
}
