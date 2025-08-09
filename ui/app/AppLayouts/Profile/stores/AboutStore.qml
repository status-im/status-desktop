import QtQuick

QtObject {

    readonly property QtObject _d: QtObject {
        id: d
        property var aboutModuleInst: aboutModule
    }

    readonly property bool fetchingUpdate: d.aboutModuleInst.fetching

    function getCurrentVersion() {
        return d.aboutModuleInst.getCurrentVersion().replace(/^v/, '')
    }

    function getGitCommit() {
        return d.aboutModuleInst.getGitCommit()
    }

    function getStatusGoVersion() {
        return d.aboutModuleInst.getStatusGoVersion()
    }

    function nodeVersion() {
        return d.aboutModuleInst.nodeVersion()
    }

    function checkForUpdates() {
        d.aboutModuleInst.checkForUpdates()
    }
}
