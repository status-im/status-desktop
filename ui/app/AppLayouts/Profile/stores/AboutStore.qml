import QtQuick 2.15

QtObject {
    property var aboutModuleInst: aboutModule

    readonly property bool fetchingUpdate: aboutModuleInst.fetching

    function getCurrentVersion() {
        return aboutModuleInst.getCurrentVersion().replace(/^v/, '')
    }

    function getGitCommit() {
        return aboutModuleInst.getGitCommit()
    }

    function getStatusGoVersion() {
        return aboutModuleInst.getStatusGoVersion()
    }

    function nodeVersion() {
        return aboutModuleInst.nodeVersion()
    }

    function checkForUpdates() {
        aboutModuleInst.checkForUpdates()
    }
}
