import QtQuick 2.13
import utils 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

QtObject {
    id: root

    property var devicesModule
    property var syncModule

    property var devicesModel: devicesModule ?  devicesModule.model : null

    // Module Properties
    property bool isDeviceSetup: devicesModule ? devicesModule.isDeviceSetup : false

    readonly property int localPairingState: devicesModule ? devicesModule.localPairingState : -1
    readonly property string localPairingError: devicesModule ? devicesModule.localPairingError : ""
    readonly property string localPairingInstallationId: devicesModule ? devicesModule.localPairingInstallationId : ""
    readonly property string localPairingInstallationName: devicesModule ? devicesModule.localPairingInstallationName : ""
    readonly property string localPairingInstallationDeviceType: devicesModule ? devicesModule.localPairingInstallationDeviceType : ""
    
    // Backup import properties
    readonly property int backupImportState: syncModule ? syncModule.backupImportState : 0
    readonly property string backupImportError: syncModule ? syncModule.backupImportError : ""
    readonly property string backupPath: d.appSettingsInst.backupPath

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d
        readonly property var appSettingsInst: appSettings
        readonly property var globalUtilsInst: globalUtils
    }

    function setBackupPath(path) {
        d.appSettingsInst.setBackupPath(path)
    }

    function toFileUri(path) {
        return d.globalUtilsInst.toFileUri(path)
    }

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
        root.devicesModule.inputConnectionStringForBootstrapping(connectionString)
    }

    function importLocalBackupFile(filePath: string) {
        root.syncModule.importLocalBackupFile(filePath)
    }
}
