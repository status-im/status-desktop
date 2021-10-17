pragma Singleton

import QtQuick 2.13

QtObject {
    property var loginModuleInst: loginModule
    property var currentAccount: loginModuleInst.selectedAccount

    function login(password) {
        loginModuleInst.login(password)
    }

    function setCurrentAccount(index) {
        loginModuleInst.setSelectedAccountByIndex(index)
    }

    function rowCount() {
        return loginModuleInst.accountsModel.rowCount()
    }
}
