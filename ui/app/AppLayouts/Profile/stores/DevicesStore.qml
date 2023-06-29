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
    readonly property string localPairingInstallationId: devicesModule ? devicesModule.localPairingInstallationId : ""
    readonly property string localPairingInstallationName: devicesModule ? devicesModule.localPairingInstallationName : ""
    readonly property string localPairingInstallationDeviceType: devicesModule ? devicesModule.localPairingInstallationDeviceType : ""

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

    function generateConnectionStringAndRunSetupSyncingPopup() {
        root.devicesModule.generateConnectionStringAndRunSetupSyncingPopup()
    }

    function validateConnectionString(connectionString) {
        return root.devicesModule.validateConnectionString(connectionString)
    }

    function inputConnectionStringForBootstrapping(connectionString) {
        return root.devicesModule.inputConnectionStringForBootstrapping(connectionString)
    }
}
